"""Validated unit data for designer tools; stdlib only, no game-engine dependency.

Both loaders consume data/balance/units.schema.json. This implements its bounded
keyword subset, not arbitrary JSON Schema. Simulation remains in CombatWorld so
Python cannot drift into a second set of combat rules.
"""
from __future__ import annotations

import copy
import hashlib
import json
import math
from pathlib import Path
import re
from dataclasses import dataclass
from typing import Any

ROOT = Path(__file__).resolve().parents[1]
DEFAULT_DB = ROOT / 'data/balance/units.v1.json'
SCHEMA_PATH = ROOT / 'data/balance/units.schema.json'
MAX_BYTES = 1_048_576
CORE = {'peasant_flailman': 'FLAILMAN', 'radical_preacher': 'RADICAL_PREACHER',
        'landsknecht_pikeman': 'LANDSKNECHT', 'heavy_gendarme': 'ARMOURED_RITTER'}


class BalanceError(ValueError):
    """A candidate database failed; keep using the previous revision."""


def validate(document: Any) -> None:
    schema = json.loads(SCHEMA_PATH.read_text(encoding='utf-8'))
    errors: list[str] = []

    def visit(value: Any, rule: dict, path: str) -> None:
        if len(errors) >= 32:
            return
        if '$ref' in rule:
            visit(value, schema['$defs'][rule['$ref'].split('/')[2]], path)
            return
        numeric = type(value) in (int, float)
        finite = numeric and math.isfinite(value)
        kind = rule.get('type')
        valid = {None: True, 'object': type(value) is dict, 'array': type(value) is list,
                 'string': type(value) is str, 'boolean': type(value) is bool,
                 'number': finite, 'integer': finite and value == math.floor(value)}.get(kind, False)
        if not valid:
            errors.append(f'{path}: expected {kind}')
            return
        if 'enum' in rule and value not in rule['enum']:
            errors.append(f'{path}: unsupported value')
        if numeric:
            for keyword, fails in [('minimum', lambda x: value < x), ('maximum', lambda x: value > x),
                                   ('exclusiveMaximum', lambda x: value >= x)]:
                if keyword in rule and fails(rule[keyword]):
                    errors.append(f'{path}: violates {keyword}')
        if isinstance(value, str):
            if not rule.get('minLength', 0) <= len(value) <= rule.get('maxLength', 2**31):
                errors.append(f'{path}: invalid string length')
            if 'pattern' in rule and re.search(rule['pattern'], value) is None:
                errors.append(f'{path}: invalid identifier')
        if isinstance(value, list):
            if not rule.get('minItems', 0) <= len(value) <= rule.get('maxItems', 2**31):
                errors.append(f'{path}: invalid array length')
            for i, item in enumerate(value):
                if rule.get('uniqueItems') and item in value[:i]:
                    errors.append(f'{path}: duplicate array item')
                if 'items' in rule:
                    visit(item, rule['items'], f'{path}[{i}]')
        if isinstance(value, dict):
            for key in rule.get('required', []):
                if key not in value:
                    errors.append(f'{path}.{key}: missing field')
            properties = rule.get('properties', {})
            for key, item in value.items():
                if 'propertyNames' in rule:
                    visit(key, rule['propertyNames'], f'{path}.{key}')
                if key in properties:
                    visit(item, properties[key], f'{path}.{key}')
                elif isinstance(rule.get('additionalProperties'), dict):
                    visit(item, rule['additionalProperties'], f'{path}.{key}')
                elif rule.get('additionalProperties') is False:
                    errors.append(f'{path}.{key}: unknown field')

    visit(document, schema, '$')
    if not errors:
        names: set[str] = set()
        kinds: set[str] = set()
        core = CORE.copy()
        for row in document['units']:
            uid = row['id']
            for name in [uid, *row['aliases']]:
                if name in names:
                    errors.append(f'{uid}: duplicate ID/alias {name}')
                names.add(name)
            if row['kind'] in kinds:
                errors.append(f'{uid}: duplicate engine kind')
            kinds.add(row['kind'])
            if core.get(uid) == row['kind']:
                del core[uid]
            c = row['combat']
            if c['minimum_range_tiles'] > c['range_tiles']:
                errors.append(f'{uid}: minimum range exceeds maximum')
            if c['attack'] == 0:
                if c['attack_period'] != 0 or c['bonus_damage'] or c['impact_fraction'] != 0:
                    errors.append(f'{uid}: non-attacker needs zero period/marker and no counters')
            elif c['attack_period'] < .05:
                errors.append(f'{uid}: attack period must be at least one 20 Hz tick')
            z = row['zeal']
            if z['enabled'] and (row['kind'] != 'RADICAL_PREACHER' or row['faction'] != 'bundschuh' or z['radius_tiles'] <= 0):
                errors.append(f'{uid}: Zeal requires a Bundschuh Preacher and positive radius')
        if core:
            errors.append('Missing/renamed core unit or wrong kind: ' + ', '.join(core))
    if errors:
        raise BalanceError('\n'.join(errors))


@dataclass(frozen=True)
class UnitSnapshot:
    """A defensive copy; callers may edit their copy without changing a database."""
    sha256: str
    balance_id: str
    _data: dict

    def document(self) -> dict:
        return copy.deepcopy(self._data)

    def unit(self, identifier: str) -> dict:
        for unit in self._data['units']:
            if identifier == unit['id'] or identifier in unit['aliases']:
                return copy.deepcopy(unit)
        raise BalanceError(f'Unknown unit: {identifier}')


def loads(raw: bytes) -> UnitSnapshot:
    if len(raw) > MAX_BYTES:
        raise BalanceError('Unit database exceeds 1 MiB')
    try:
        def pairs(items: list[tuple[str, Any]]) -> dict:
            result = {}
            for key, value in items:
                if key in result:
                    raise BalanceError('Duplicate object key: ' + key)
                result[key] = value
            return result

        document = json.loads(raw.decode('utf-8'), object_pairs_hook=pairs,
                              parse_constant=lambda x: (_ for _ in ()).throw(ValueError(x)))

        def depth_and_unicode(value: Any, depth: int = 0) -> None:
            if depth > 32:
                raise BalanceError('JSON nesting exceeds 32')
            if isinstance(value, str):
                value.encode('utf-8')  # Reject lone surrogate escapes, like the engine syntax guard.
            if isinstance(value, dict):
                for key, item in value.items():
                    depth_and_unicode(key, depth + 1)
                    depth_and_unicode(item, depth + 1)
            elif isinstance(value, list):
                for item in value:
                    depth_and_unicode(item, depth + 1)

        depth_and_unicode(document)
        validate(document)
    except (ValueError, UnicodeError, OverflowError, RecursionError) as error:
        raise BalanceError(str(error)) from error
    return UnitSnapshot(hashlib.sha256(raw).hexdigest(), document['balance_id'], copy.deepcopy(document))


def load(path: str | Path = DEFAULT_DB) -> UnitSnapshot:
    try:
        with Path(path).open('rb') as stream:
            return loads(stream.read(MAX_BYTES + 1))
    except OSError as error:
        raise BalanceError(str(error)) from error


class UnitDatabase:
    """Publish only validated revisions; a rejected edit leaves the last good one."""
    def __init__(self, path: str | Path = DEFAULT_DB):
        self.path = Path(path)
        self.generation = 0
        self.snapshot: UnitSnapshot | None = None
        self.reload()

    def reload(self) -> bool:
        candidate = load(self.path)
        if self.snapshot is not None and candidate.sha256 == self.snapshot.sha256:
            return False
        self.snapshot = candidate
        self.generation += 1
        return True

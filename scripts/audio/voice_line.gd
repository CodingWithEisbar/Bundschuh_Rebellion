class_name RtsVoiceLine
extends Resource
## Production VO slots. A missing stream is subtitle-only, never a blocking load.
## The shipped text is a modernized casting draft, not certified historical speech.

@export var id: StringName
@export_enum("Bundschuh", "Swabian League") var faction: int = 0
@export_enum("selected", "move", "attack") var action: String = "selected"
@export var text_de: String = ""
@export var subtitle_vi: String = ""
@export var stream: AudioStream
@export var language_approved: bool = false
@export var provenance: String = "Casting draft; actor recording pending"

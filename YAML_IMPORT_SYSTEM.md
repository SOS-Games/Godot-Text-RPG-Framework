# YAML Import System for Fantasy Idle Game

This system provides a lightweight, modular YAML import framework for managing game entities with type-safe references, schema validation, and dependency ordering.

## Overview

The system:
- **Loads entity data** from YAML files organized by category (skills, items, mobs, locations, action-nodes, npcs)
- **Validates structure** against JSON Schema Draft-7 schemas
- **Resolves references** between entities with type checking
- **Tracks errors** and validation reports for debugging
- **Respects import order** to ensure dependencies are loaded first (e.g., skills before items)

## Architecture

### Entity Classes (`entities/`)

Each category has a typed GDScript class extending `GameEntity`:

- **`GameEntity`** — Base class with `id` and `name`
- **`Skill`** — Skills with a `level` property
- **`Item`** — Items that reference a skill via `equip_skill_id`
- **`Mob`** — Mobs with a `level` property
- **`ActionNode`** — Harvestable resources (trees, ore, etc.)
- **`Location`** — Locations linking to mobs and action-nodes via `mob_ids` and `action_node_ids`

### Data Files (`data/`)

YAML files organized by category:
```
data/
  skills.yaml        # Array of skills
  items.yaml         # Array of items
  mobs.yaml          # Array of mobs
  action-nodes.yaml  # Array of action-nodes
  locations.yaml     # Array of locations
  npcs.yaml          # Array of npcs (untyped, extensible)
```

Each file has a `$schema` field for auto-discovery during validation.

### Schemas (`schemas/`)

JSON Schema files that validate data structure:
- Ensure required fields are present (id, name)
- Check field types (integers are integers, arrays are arrays)
- Document expected properties

Schemas are optional; the importer works without them but won't catch structural errors.

### DataImporter (`data_importer.gd`)

Main class that orchestrates the import pipeline:

```gdscript
var importer = DataImporter.new()
var success = importer.import_all()

if not success:
    for error in importer.get_errors():
        print("Error: ", error)

var skills = importer.get_entities("skills")
var items = importer.get_entities("items")
```

**Key methods:**
- `import_all() -> bool` — Run the full import pipeline
- `get_entities(category: String) -> Dictionary` — Retrieve all entities in a category
- `get_errors() -> Array` — Retrieve parse/validation errors
- `get_validation_reports() -> Array` — Retrieve detailed validation error objects

**Import Order:**
References are resolved after all categories are imported. The import order is:
1. skills
2. items
3. npcs
4. mobs
5. locations
6. action-nodes
7. (any remaining categories)

This ensures dependencies are loaded first (e.g., skills exist before items reference them).

## Reference Validation

References between entities are **type-constrained** via `_reference_type_map`:

| Field Name | Expected Type |
|---|---|
| `equip_skill_id` | skills |
| `mob_ids` | mobs |
| `action_node_ids` | action-nodes |
| `inventory_ids` | items |
| `npc_ids` | npcs |

**Example:** A location's `mob_ids` field can *only* reference mob entities. If you try to reference an action-node there, the importer will report an unresolved reference error.

## Resolved References

References are stored as `__resolved` keys alongside the original ID fields:

```gdscript
# items.yaml
items:
  - id: "items:sword"
    equip_skill_id: "skills:combat"

# After import, the item object has:
{
  "id": "items:sword",
  "equip_skill_id": "skills:combat",
  "equip_skill_id__resolved": { "id": "skills:combat", "name": "Combat", "level": 1 }
}
```

This lets you access both the ID (for serialization) and the resolved entity (for runtime lookups).

## Error Handling

### Parse Errors
Occur when YAML syntax is invalid. The importer stops parsing that file.

### Validation Errors
Occur when data doesn't match the schema (missing required field, wrong type, etc.).
Validation reports are collected and available via `get_validation_reports()`.

### Reference Errors
Occur when a reference points to a non-existent entity or an entity of the wrong type.

**Example error output:**
```
Import completed with errors:
 - Unresolved reference in array: locations.locations:mines -> action-nodes:tree_oak
```

This means: Location "locations:mines" has an invalid reference to "action-nodes:tree_oak" in an array field that expects mobs.

## Configuration

`DataImporter` has two export variables:

```gdscript
@export var schemas_dir: String = "res://schemas"
@export var data_dirs: Array = ["res://data"]
```

You can set these in the editor or in code:
```gdscript
importer.schemas_dir = "res://custom_schemas"
importer.data_dirs = ["res://data", "res://mods/data"]
```

## Extending the System

### Adding a New Entity Type

1. Create a new class in `entities/`:
```gdscript
class_name NPC extends GameEntity

var faction: String

func _init(p_id: String = "", p_name: String = "", p_faction: String = "") -> void:
	super(p_id, p_name)
	faction = p_faction

static func deserialize(data: Variant):
	if typeof(data) != TYPE_DICTIONARY:
		return YAMLResult.error("NPC expects Dictionary")
	var d: Dictionary = data
	return NPC.new(d.get("id", ""), d.get("name", ""), d.get("faction", ""))

func serialize() -> Dictionary:
	var base = super.serialize()
	base["faction"] = faction
	return base

func get_entity_type() -> String:
	return "npcs"
```

2. Register the class in `DataImporter._register_entity_classes()`:
```gdscript
YAML.register_class(NPC)
```

3. Add the category to `import_order` if it has dependencies:
```gdscript
import_order = ["skills", "items", "npcs", "mobs", "locations", "action-nodes"]
```

4. (Optional) Create a schema in `res://schemas/npcs_schema.yaml`:
```yaml
$id: "http://game/schemas/npcs.yaml"
type: object
properties:
  npcs:
    type: array
    items:
      type: object
      properties:
        id:
          type: string
        name:
          type: string
        faction:
          type: string
      required: [id, name]
```

5. Create data in `res://data/npcs.yaml`:
```yaml
npcs:
  - id: "npcs:merchant"
    name: "Bob"
    faction: "neutral"
```

### Adding Reference Constraints

To constrain a field to a specific entity type, add it to `_reference_type_map`:

```gdscript
var _reference_type_map: Dictionary = {
	"faction_leader_id": "npcs",  # NPC factions can have leader references
}
```

## Testing

A test runner is provided in `test_importer.gd`:

```gdscript
extends Node

func _ready():
	var importer = DataImporter.new()
	var ok = importer.import_all()
	# ... prints entities and errors
```

Add this node to your scene and run it to see the import output.

## Future Enhancements

- [ ] Support circular references with deferred resolution
- [ ] Batch validation and fail-fast mode
- [ ] Entity inheritance and mixins
- [ ] Custom serializers for complex types
- [ ] Schema generation from entity classes
- [ ] Import/export with mod support

## License

Part of the Fantasy Idle Grinding RPG project.

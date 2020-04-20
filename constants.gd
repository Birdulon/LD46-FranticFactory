tool
extends Node

enum MATERIAL_TYPE {iORE, iSTOCK, iROD, iLADDER, iLADDER2, iLADDER4, iMOLTEN}
enum MACHINE_TYPE {SMELTER, FORGE, LATHE, WELDER}

var RECIPES = {
	MACHINE_TYPE.SMELTER: {input=MATERIAL_TYPE.iORE, output=MATERIAL_TYPE.iMOLTEN, time=4.0},
	MACHINE_TYPE.FORGE: {input=MATERIAL_TYPE.iMOLTEN, output=MATERIAL_TYPE.iSTOCK, time=4.0},
	MACHINE_TYPE.LATHE: {input=MATERIAL_TYPE.iSTOCK, output=MATERIAL_TYPE.iROD, time=4.0},
	MACHINE_TYPE.WELDER: {input=MATERIAL_TYPE.iROD, output=MATERIAL_TYPE.iLADDER, time=4.0},
}

onready var MACHINE_SCENES = {
	MACHINE_TYPE.SMELTER: load("res://machines/Smelter.tscn"),
	MACHINE_TYPE.FORGE: load("res://machines/Forge.tscn"),
	MACHINE_TYPE.LATHE: load("res://machines/Lathe.tscn"),
	MACHINE_TYPE.WELDER: load("res://machines/Welder.tscn"),
}

onready var MATERIAL_SCENES = {
	MATERIAL_TYPE.iORE: load("res://objects/IronOre.tscn"),
	MATERIAL_TYPE.iSTOCK: load("res://objects/IronStock.tscn"),
	MATERIAL_TYPE.iROD: load("res://objects/IronRod.tscn"),
	MATERIAL_TYPE.iLADDER: load("res://objects/SmallLadder.tscn"),
	MATERIAL_TYPE.iLADDER2: load("res://objects/MedLadder.tscn"),
	MATERIAL_TYPE.iLADDER4: load("res://objects/BigLadder.tscn"),
}

var font = preload("res://assets/UI_module_names.tres")

#include "includes.inc"
params ["_target", ["_texture", controlNull]];

private _displayName = [_target] call WL2_fnc_getAssetTypeName;
private _assetSector = BIS_WL_allSectors select { _target inArea (_x getVariable "objectAreaComplete") };
private _assetLocation = if (count _assetSector > 0) then {
	(_assetSector # 0) getVariable ["WL2_name", str (mapGridPosition _target)];
} else {
	mapGridPosition _target;
};

private _result = ["Delete asset", format ["Are you sure you would like to delete: %1 @ %2", _displayName, _assetLocation], "Yes", "Cancel"] call WL2_fnc_prompt;

if (_result) then {
	private _access = [_target, player, "full"] call WL2_fnc_accessControl;
	if !(_access # 0) exitWith {
		systemChat format ["Cannot remove: %1", _access # 1];
		playSound "AddItemFailed";
	};

	if (!alive player || lifeState player == "INCAPACITATED") exitWith {
		systemChat "You are dead!";
		playSound "AddItemFailed";
	};

	if (alive _target && _target isKindOf "Air" && speed _target > 5 && !(unitIsUAV _target)) exitWith {
		systemChat "Can't remove flying aircraft!";
		playSound "AddItemFailed";
	};

	playSound "AddItemOK";
	[format [toUpper localize "STR_A3_WL_popup_asset_deleted", toUpper _displayName], 2] spawn WL2_fnc_smoothText;
	_vehicles = missionNamespace getVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], []];
	_vehicles deleteAt (_vehicles find _target);
	missionNamespace setVariable [format ["BIS_WL_ownedVehicles_%1", getPlayerUID player], _vehicles, true];

	if (_target == (getConnectedUAV player)) then {
		player connectTerminalToUAV objNull;
	};

	if (unitIsUAV _target) then {
		private _grp = group effectiveCommander _target;
		{_target deleteVehicleCrew _x} forEach crew _target;
		deleteGroup _grp;
	};

	deleteVehicle _target;
	((ctrlParent WL_CONTROL_MAP) getVariable "BIS_sectorInfoBox") ctrlShow false;
	((ctrlParent WL_CONTROL_MAP) getVariable "BIS_sectorInfoBox") ctrlEnable true;

	if (!isNull _texture) then {
		[_texture] call WL2_fnc_sendVehicleData;
	};
} else {
	playSound "AddItemFailed";
};
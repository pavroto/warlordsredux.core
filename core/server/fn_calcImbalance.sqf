#include "includes.inc"

private _playersWest = 0;
private _playersEast = 0;

{
  if ( _x getVariable ["WL2_afk", false] ) then { continue };
  if ( side group _x == west ) then { _playersWest = _playersWest + 1 };
  if ( side group _x == east ) then { _playersEast = _playersEast + 1 };
} forEach allPlayers;

_playersWest = _playersWest max 1;
_playersEast = _playersEast max 1;
private _multiplier = _playersWest / (_playersWest + _playersEast) * 2;

private _incomeWest = round ((west call WL2_fnc_income) * (2 - _multiplier));
private _incomeEast = round ((east call WL2_fnc_income) * _multiplier);
missionNamespace setVariable ["WL2_actualIncome_west", _incomeWest max 50, true];
missionNamespace setVariable ["WL2_actualIncome_east", _incomeEast max 50, true];
(* Copyright 2009 Heriot-Watt University
 * Copyright 2010 Heriot-Watt University
 *
 *
 * This file is part of the ULTRA SML Type Error Slicer (SMLTES) -
 * a Type Error Slicer for Standard ML written by the ULTRA Group of
 * Heriot-Watt University, Edinburgh.
 *
 * SMLTES is a free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * SMLTES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with SMLTES.  If not, see <http://www.gnu.org/licenses/>.
 *
 *  o Authors:     Vincent Rahli
 *  o Affiliation: Heriot-Watt University, MACS
 *  o Date:        24 May 2010
 *  o File name:   Enumeration.sig
 *  o Description: Defines the signature ENUM for the enumeration algorithm.
 *)


signature ENUM = sig

    val preEnum  : Env.envcss   ->
		   AstSML.packs ->
		   Error.error list *
		   SearchSpace.searchSpace

    (* Both of them return false if the processus terminated before the time limit *)
    val enum     : Env.envcss              ->
		   Error.error list        ->
		   SearchSpace.searchSpace ->
		   LargeInt.int            ->
		   AstSML.packs            ->
		   Error.error list  *
		   bool

    val initEnum : Env.envcss              ->
		   Error.error list        ->
		   SearchSpace.searchSpace ->
		   VTimer.timer            ->
		   AstSML.packs            ->
		   Error.export' option    ->
		   int                     ->
		   Error.error list        *
		   Error.error list        *
		   SearchSpace.searchSpace *
		   int                     *
		   bool (* says whether there are more filters to test or not *)

    val runEnum  : Env.envcss              ->
		   Error.error list        ->
		   SearchSpace.searchSpace ->
		   LargeInt.int            ->
		   VTimer.timer            ->
		   AstSML.packs            ->
		   Error.export' option    ->
		   int                     ->
		   Error.error list        *
		   Error.error list        *
		   SearchSpace.searchSpace *
		   int                     *
		   bool (* says whether there are more filters to test or not *)

end

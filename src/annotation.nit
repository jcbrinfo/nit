# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Management and utilities on annotations
module annotation

import modelbuilder
private import literal
import model::mmodule_data

redef class Prod
	super ANode

	# Try to get its single annotation with a given name
	# If there is no such an annotation, null is returned.
	# If there is more than one annotation, a error message is printed and the first annotation is returned
	fun get_single_annotation(name: String, modelbuilder: ModelBuilder): nullable AAnnotation
	do
		var res = get_annotations(name)
		if res.is_empty then return null
		if res.length > 1 then
			modelbuilder.error(res[1], "Error: multiple annotation `{name}`. A previous one is defined line {res[0].location.line_start}")
		end
		return res.first
	end

	# Return all its annotations of a given name in the order of their declaration
	# Retun an empty array if no such an annotation.
	fun get_annotations(name: String): Array[AAnnotation]
	do
		var res = new Array[AAnnotation]
		var nas = n_annotations
		if nas == null then return res
		for na in nas.n_items do
			if na.name != name then continue
			res.add(na)
		end
		return res
	end
end

redef class AAnnotation
	# The name of the annotation
	fun name: String
	do
		return n_atid.n_id.text
	end

	# Get the single argument of `self` as a `String`.
	# Raise error and return null on any inconsistency.
	fun arg_as_string(modelbuilder: ModelBuilder): nullable String
	do
		var args = n_args
		if args.length == 1 then
			var arg = args.first.as_string
			if arg != null then return arg
		end

		modelbuilder.error(self, "Annotation error: \"{name}\" expects a single String as argument.")
		return null
	end

	# Get the single argument of `self` as an `Int`.
	# Raise error and return null on any inconsistency.
	fun arg_as_int(modelbuilder: ModelBuilder): nullable Int
	do
		var args = n_args
		if args.length == 1 then
			var arg = args.first.as_int
			if arg != null then return arg
		end

		modelbuilder.error(self, "Annotation error: \"{name}\" expects a single Int as argument.")
		return null
	end

	# Get the single argument of `self` as an identifier.
	# Raise error and return null on any inconsistency.
	fun arg_as_id(modelbuilder: ModelBuilder): nullable String
	do
		var args = n_args
		if args.length == 1 then
			var arg = args.first.as_id
			if arg != null then return arg
		end

		modelbuilder.error(self, "Annotation error: \"{name}\" expects a single identifier as argument.")
		return null
	end
end

redef class AAtArg
	# Get `self` as a `String`.
	# Return null if not a string.
	fun as_string: nullable String
	do
		if not self isa AExprAtArg then return null
		var nexpr = n_expr
		if not nexpr isa AStringFormExpr then return null
		return nexpr.value.as(not null)
	end

	# Get `self` as an `Int`.
	# Return null if not an integer.
	fun as_int: nullable Int
	do
		if not self isa AExprAtArg then return null
		var nexpr = n_expr
		if not nexpr isa AIntExpr then return null
		return nexpr.value.as(not null)
	end

	# Get `self` as a single identifier.
	# Return null if not a single identifier.
	fun as_id: nullable String
	do
		if not self isa AExprAtArg then return null
		var nexpr = n_expr
		if not nexpr isa ACallExpr then return null
		if not nexpr.n_expr isa AImplicitSelfExpr then return null
		if not nexpr.n_args.n_exprs.is_empty then return null
		return nexpr.n_id.text
	end
end

redef class ModelBuilder
	# Collect all annotations by `name` assocated to `mmodule` and its imported modules.
	# Note that visibility is not considered.
	fun collect_annotations_on_modules(name: String, mmodule: MModule): Array[AAnnotation]
	do
		var annotations = new Array[AAnnotation]
		for mmod in mmodule.in_importation.greaters do
			if not mmodule2nmodule.keys.has(mmod) then continue
			var amod = mmodule2nmodule[mmod]
			var module_decl = amod.n_moduledecl
			if module_decl == null then continue
			var aas = module_decl.get_annotations(name)
			annotations.add_all aas
		end
		return annotations
	end

	# Return the single annotation `name` locally assocated to `mmodule`, if any.
	# Obviously, if there is no ast associated to `mmodule`, then nothing is returned.
	fun get_mmodule_annotation(name: String, mmodule: MModule): nullable AAnnotation
	do
		if not mmodule2nmodule.keys.has(mmodule) then return null
		var amod = mmodule2nmodule[mmodule]
		var module_decl = amod.n_moduledecl
		if module_decl == null then return null
		var res = module_decl.get_single_annotation(name, self)
		return res
	end

	private var collect_annotations_data_cache = new HashMap[String, MModuleData[AAnnotation]]

	# Collect all annotations by `name` in `mmodule` and its importations (direct and indirect)
	# Note that visibility is not considered.
	fun collect_annotations_data(name: String, mmodule: MModule): MModuleData[AAnnotation]
	do
		var res = collect_annotations_data_cache.get_or_null(name)
		if res == null then
			res = new MModuleData[AAnnotation](model)
			collect_annotations_data_cache[name] = res
		end

		for mmod in mmodule.in_importation.greaters do
			if res.has_mmodule(mmod) then continue
			var ass = get_mmodule_annotation(name, mmod)
			if ass == null then continue
			res[mmod] = ass
		end
		return res
	end

	# Get an annotation by name from `mmodule` and its super modules. Will recursively search
	# in imported module to find the "latest" declaration and detects priority conflicts.
	fun lookup_annotation_on_modules(name: String, mmodule: MModule): nullable AAnnotation
	do
		var data = collect_annotations_data(name, mmodule)
		var annotations = data.lookup_values(mmodule, none_visibility)
		if annotations.is_empty then return null
		if annotations.length > 1 then
			var locs = new Array[Location]
			for annot in annotations do locs.add(annot.location)

			toolcontext.error(mmodule.location,
				"Priority conflict on annotation {name}, it has been defined in: {locs.join(", ")}")
		end
		return annotations.first
	end
end
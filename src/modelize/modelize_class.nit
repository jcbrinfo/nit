# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2012 Jean Privat <jean@pryen.org>
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

# Analysis and verification of class definitions to instantiate model element
module modelize_class

import modelbuilder

# TODO: Remove once `subset` is a keyword.
import annotation

redef class ToolContext
	# Run `AModule::build_classes` on each module
	var modelize_class_phase: Phase = new ModelizeClassPhase(self, null)
end

private class ModelizeClassPhase
	super Phase

	redef fun process_nmodule(nmodule)
	do
		toolcontext.modelbuilder.build_classes(nmodule)
	end
end

redef class ModelBuilder
	# Visit the AST and create the `MClass` objects
	private fun build_a_mclass(nmodule: AModule, nclassdef: AClassdef)
	do
		var mmodule = nmodule.mmodule.as(not null)

		var name: String
		var nkind: nullable AClasskind
		var mkind: MClassKind
		var nvisibility: nullable AVisibility
		var mvisibility: nullable MVisibility
		var arity = 0
		var names = new Array[String]
		var mclass
		if nclassdef isa AStdClassdef then
			var qid = nclassdef.n_qid
			assert qid != null
			name = qid.n_id.text
			nkind = nclassdef.n_classkind
			mkind = nkind.mkind
			nvisibility = nclassdef.n_visibility
			mvisibility = nvisibility.mvisibility
			arity = nclassdef.n_formaldefs.length

			# TODO: Remove once `subset` is a keyword.
			if nclassdef.get_single_annotation("subset", self) != null then
				mkind = subset_kind
			end

			if mvisibility == protected_visibility then
				error(nvisibility, "Error: only properties can be protected.")
				return
			else if mvisibility == intrude_visibility then
				error(nvisibility, "Error: intrude is not a legal visibility for classes.")
				return
			end
			# Collect formal parameter names
			for i in [0..arity[ do
				var nfd = nclassdef.n_formaldefs[i]
				var ptname = nfd.n_id.text
				if names.has(ptname) then
					error(nfd, "Error: a formal parameter type `{ptname}` already exists.")
					return
				end
				for c in ptname.chars do if c >= 'a' and c<= 'z' then
					warning(nfd, "formal-type-name", "Warning: lowercase in the formal parameter type `{ptname}`.")
					break
				end
				names.add(ptname)
			end
			mclass = try_get_mnominal_by_qid(qid, mmodule)
			if mclass == null and (qid.n_qualified != null or nclassdef.n_kwredef != null) then
				class_not_found(qid, mmodule)
				nclassdef.is_broken = true
				return
			end

		else if nclassdef isa ATopClassdef and nclassdef.n_propdefs.first.as(AMethPropdef).n_methid.collect_text == "sys" then
			# Special case to keep `sys` in object.
			# Needed to keep working bootstrap and a working java FFI together.
			# TODO: remove once safe to remove
			name = "Object"
			nkind = null
			mkind = interface_kind
			nvisibility = null
			mvisibility = public_visibility
			mclass = try_get_mnominal_by_name(nclassdef, mmodule, name)
		else
			name = "Sys"
			nkind = null
			mkind = concrete_kind
			nvisibility = null
			mvisibility = public_visibility
			mclass = try_get_mnominal_by_name(nclassdef, mmodule, name)
		end

		if mclass == null then
			# Check for conflicting class full-names in the package
			if mmodule.mgroup != null and mvisibility >= protected_visibility then
				var mclasses = model.get_mnominals_by_name(name)
				if mclasses != null then for other in mclasses do
					if other.intro_mmodule.mgroup != null and other.intro_mmodule.mgroup.mpackage == mmodule.mgroup.mpackage then
						# Skip classes that are buggy
						if other.try_intro == null then continue
						warning(nclassdef, "full-name-conflict", "Error: a class named `{other.full_name}` is already defined in module `{other.intro_mmodule}` at {other.intro.location}.")
						break
					end
				end
			end

			mclass = new MNominal(mmodule, name, nclassdef.location, names,
					mkind, mvisibility)
			#print "new class {mclass}"
		else if nclassdef isa AStdClassdef and nmodule.mclass2nclassdef.has_key(mclass) then
			error(nclassdef, "Error: a class `{name}` is already defined at line {nmodule.mclass2nclassdef[mclass].location.line_start}.")
			mclass.is_broken = true
			return
		else if nclassdef isa AStdClassdef and nclassdef.n_kwredef == null then
			error(nclassdef, "Redef Error: `{name}` is an imported class. Add the `redef` keyword to refine it.")
			mclass.is_broken = true
			return
		else if arity != 0 and mclass.arity != arity then
			error(nclassdef, "Redef Error: expected {mclass.arity} formal parameter(s) for {mclass.signature_to_s}; got {arity}.")
			mclass.is_broken = true
			return
		else if nkind != null and mkind != concrete_kind and mclass.kind != mkind then
			error(nkind, "Redef Error: refinement changed the kind from `{mclass.kind}` to `{mkind}`.")
		else if nvisibility != null and mvisibility != public_visibility and mclass.visibility != mvisibility then
			error(nvisibility, "Redef Error: refinement changed the visibility from `{mclass.visibility}` to `{mvisibility}`")
		end
		nclassdef.mclass = mclass
		if not nmodule.mclass2nclassdef.has_key(mclass) then
			nmodule.mclass2nclassdef[mclass] = nclassdef
			nclassdef.all_defs = [nclassdef]
		else
			nmodule.mclass2nclassdef[mclass].all_defs.add(nclassdef)
		end
	end

	# Visit the AST and create the `MClassDef` objects
	private fun build_a_mclassdef(nmodule: AModule, nclassdef: AClassdef)
	do
		var mmodule = nmodule.mmodule.as(not null)
		var mclass = nclassdef.mclass
		if mclass == null then return # Skip error

		# In case of non-standard AClassdef, try to attach to an already existing mclassdef
		var other_nclassdef = nmodule.mclass2nclassdef[mclass]
		if other_nclassdef != nclassdef then
			assert not nclassdef isa AStdClassdef
			nclassdef.mclassdef = other_nclassdef.mclassdef
			return
		end

		# In the case of a subset definition, the declared supertype or the base
		# class.
		var subset_supertype: nullable MClassType = null
		var data_class: nullable MClass
		var is_nominal_intro = mclass.mclassdefs.is_empty
		# Do we have to set `data_class` as the base class?
		var set_base_class = false
		if mclass isa MSubset then
			subset_supertype = get_subset_supertype(nmodule, nclassdef,
					is_nominal_intro)
			if subset_supertype == null then
				if is_nominal_intro then
					mclass.is_broken = true
					# The class is so broken that some attributes can not be
					# initialized.
					mclass.unlink
				end
				# Go back to a state before we looked at the supertypes. That
				# way, `build_classes` won’t check them and won’t try to use
				# the references to the type parameters of the invalid
				# definition.
				unresolve_supertypes(nclassdef)
				return
			end
			data_class = subset_supertype.mnominal.as(MClass)
			if is_nominal_intro then
				mclass.data_class = data_class
				set_base_class = true
			end
		else
			assert mclass isa MClass
			data_class = mclass
		end
		# FIXME: Workaround
		assert mclass isa MNominal

		var bound_mtype = get_bound_mtype(nmodule, nclassdef, subset_supertype,
				is_nominal_intro)
		if bound_mtype == null then
			if subset_supertype != null then
				# Go back to a state before we looked at the supertypes. That
				# way, `build_classes` won’t check them and won’t try to use
				# the references to the type parameters of the invalid
				# definition.
				unresolve_supertypes(nclassdef)
			end
			return
		end

		var mclassdef = new MClassDef(mmodule, bound_mtype, nclassdef.location)
		nclassdef.mclassdef = mclassdef
		self.mclassdef2nclassdef[mclassdef] = nclassdef
		if set_base_class then mclassdef.set_supertypes([data_class.mclass_type])

		if nclassdef isa AStdClassdef then
			var ndoc = nclassdef.n_doc
			if ndoc != null then
				var mdoc = ndoc.to_mdoc
				mclassdef.mdoc = mdoc
				mdoc.original_mentity = mclassdef
			else if mclassdef.is_nominal_intro and mclass.visibility >= public_visibility then
				advice(nclassdef, "missing-doc", "Documentation warning: Undocumented public class `{mclass}`")
			end
		end

		if mclassdef.is_nominal_intro then
			self.toolcontext.info("{mclassdef} introduces new {mclass.kind} {mclass.full_name}", 3)
		else
			self.toolcontext.info("{mclassdef} refines {mclass.kind} {mclass.full_name}", 3)
		end
	end

	# Visit the AST and return the bound type of the specified class definition.
	#
	# In case of error, return `null`.
	#
	# `subset_supertype` corresponds to the `super` declaration (or the implied
	# base class) in a type subset definition. It must be `null` for other class
	# kinds.
	private fun get_bound_mtype(nmodule: AModule, nclassdef: AClassdef,
			subset_supertype: nullable MType, is_nominal_intro: Bool):
			nullable MClassType
	do
		var mmodule = nmodule.mmodule.as(not null)
		var mclass = nclassdef.mclass.as(not null)

		var bounds = new Array[MType]
		if nclassdef isa AStdClassdef and mclass.arity > 0 then
			assert subset_supertype == null or subset_supertype isa MGenericType
			var objectclass = try_get_mnominal_by_name(nmodule, mmodule,
					"Object")

			# Resolve bounds for formal parameters
			for i in [0..mclass.arity[ do

				if nclassdef.n_formaldefs.is_empty then
					var bound = get_inherited_bound(mclass, i, subset_supertype,
							is_nominal_intro)
					bounds.add(bound)
					continue
				end

				var nfd = nclassdef.n_formaldefs[i]
				var pname = mclass.mparameters[i].name
				if nfd.n_id.text != pname then
					if mclass.kind == subset_kind and is_nominal_intro then
						error(nfd.n_id, "Error: formal parameter type #{i} `{nfd.n_id.text}` must be named `{pname}` as in the original definition in base class `{mclass.data_class}`.")
					else
						error(nfd.n_id, "Error: formal parameter type #{i} `{nfd.n_id.text}` must be named `{pname}` as in the original definition in module `{mclass.intro.mmodule}`.")
					end
				else if subset_supertype != null and is_nominal_intro then
					# Each `MFormalType` of the supertype of a type subset must
					# refer to the correct type parameter in the subset’s
					# signature.
					var arg = subset_supertype.arguments[i]
					if arg isa MFormalType then
						# Ensure it is really a reference to the susbset’s
						# signature, just in case we missed an edge case.
						assert arg isa MParameterType and arg.mclass == mclass
						# Check that the indices are in sync.
						if arg.rank != i then
							# We already know that the subset’s signature use
							# the good name. So, it is the name that is in the
							# `super` declaration that is wrong.
							# TODO: Find a robust way to locate the error.
							var arg_node = nclassdef.n_superclasses.
									first.n_type.n_types[i]
							error(arg_node,
								"Error: formal parameter type #{i} `{arg}` " +
								"must be named `{pname}` as in the original " +
								"definition in module " +
								"`{mclass.data_class.intro.mmodule}`."
							)
						end
					end
				end
				var nfdt = nfd.n_type
				if nfdt != null then
					if subset_supertype != null and is_nominal_intro then
						# Since we already have a bound, the supertype must
						# not define another. Else, we have a conflict.
						# TODO: Maybe we should relax this restriction.
						var arg = subset_supertype.arguments[i]
						if not arg isa MFormalType then
							error(nfd,
								"Error: formal parameter type #{i} `{pname}` " +
								"has a bounds in both the signature and the " +
								"`super` declaration. Please remove one of " +
								"the bounds."
							)
						end
					end
					var bound = resolve_mtype_unchecked(mmodule, null, nfdt, false)
					if bound == null then return null # Forward error
					if bound.need_anchor then
						# No F-bounds!
						error(nfd, "Error: formal parameter type `{pname}` bounded with a formal parameter type.")
					else
						bounds.add(bound)
						nfd.bound = bound
					end
				else if is_nominal_intro and subset_supertype == null then
					if objectclass == null then
						error(nfd, "Error: formal parameter type `{pname}` unbounded but no `Object` class exists.")
						return null
					end
					# No bound, then implicitely bound by nullable Object
					var bound = objectclass.mclass_type.as_nullable
					bounds.add(bound)
					nfd.bound = bound
				else
					var bound = get_inherited_bound(mclass, i, subset_supertype,
							is_nominal_intro)
					bounds.add(bound)
					nfd.bound = bound
				end
			end
		end
		return mclass.get_mtype(bounds)
	end

	# Return the inherited bound of the specified type parameter.
	#
	# Used by `get_bound_mtype` when no bound is specified in the signature of
	# the class definition.
	private fun get_inherited_bound(mnominal: MNominal, parameter_index: Int,
			subset_supertype: nullable MGenericType,
			is_nominal_intro: Bool): MType
	do
		if not is_nominal_intro then
			return mnominal.intro.bound_mtype.arguments[parameter_index]
		else if subset_supertype != null and
				not subset_supertype.arguments[parameter_index].need_anchor then
			return subset_supertype.arguments[parameter_index]
		else
			return mnominal.data_class.intro.bound_mtype.arguments[
					parameter_index]
		end
	end

	# Visit the AST and return the lone supertype of the specified type subset.
	#
	# For the introducing definition, bounds that are specified in the `super`
	# declaration are included in the returned type (so that `build_a_mclassdef`
	# can include them in the `bound_mtype`).
	#
	# In case of error, return `null`.
	private fun get_subset_supertype(nmodule: AModule, nclassdef: AClassdef,
		is_nominal_intro: Bool): nullable MClassType
	do
		var mclass = nclassdef.mclass.as(not null)
		var supertypes = list_supertypes(nmodule, nclassdef, is_nominal_intro)

		if is_nominal_intro then
			# A subset can only have one direct supertype.
			if supertypes.length != 1 then
				if supertypes.is_empty then
					var mmodule = nmodule.mmodule.as(not null)
					var objectclass = try_get_mnominal_by_name(nmodule, mmodule,
							"Object")

					if objectclass == null then
						# No base class is specified and `Object` is not defined.
						error(nclassdef,
							"Error: {mclass.kind} `{mclass.name}` must have " +
							"a base class."
						)
					end
					# Else, `list_supertypes` failed and we already have an
					# error message.
				else
					error(nclassdef,
						"Error: {mclass.kind} `{mclass.name}` has multiple " +
						"base classes."
					)
				end
				return null
			end
		else if supertypes.is_empty then
			# All definitions have the same base class.
			return mclass.data_class.mclass_type
		else
			error(nclassdef,
				"Error: Only the introducing definition of " +
				"{mclass.kind} `{mclass.name}` may specify a base class."
			)
		end

		var supertype = supertypes.first
		if not supertype.mnominal isa MClass then
			# `list_supertypes` already raised an error about
			# specializations rules.
			return null
		end

		# A type subset must have the same arity than its base class.
		var data_class = supertype.mnominal
		var arity = mclass.arity
		var expected_arity = data_class.arity
		if arity != 0 and arity != expected_arity then
			error(nclassdef,
				"Error: expected {expected_arity} formal parameter(s) " +
				"for a {mclass.kind} of {data_class.signature_to_s}; " +
				"got {arity}."
			)
			return null
		end

		return supertype
	end

	# Visit the AST and set the supertypes of the `MClassDef` objects.
	#
	# Do nothing for a type subset definition because the creation of the
	# `MClassDef` itself requires to look at supertypes. In that case,
	# `build_a_mclassdef` is in charge of setting the supertype.
	private fun collect_a_mclassdef_inheritance(nmodule: AModule, nclassdef: AClassdef)
	do
		var mmodule = nmodule.mmodule
		if mmodule == null then return
		var objectclass = try_get_mnominal_by_name(nmodule, mmodule, "Object")
		var pointerclass = try_get_mnominal_by_name(nmodule, mmodule, "Pointer")
		var mclass = nclassdef.mclass
		if mclass == null then return
		var mclassdef = nclassdef.mclassdef
		if mclassdef == null then return

		# The base class of a class subset is set by `build_a_mclassdef`.
		if mclassdef.is_subset_def then return
		var supertypes = list_supertypes(nmodule, nclassdef,
				mclassdef.is_nominal_intro)
		mclassdef.set_supertypes(supertypes)
		if not supertypes.is_empty then self.toolcontext.info("{mclassdef} new super-types: {supertypes.join(", ")}", 3)
	end

	# Visit the AST and list the super-types specified or implied by the class definition.
	#
	# REQUIRE: `nmodule.mmodule != null`
	# REQUIRE: `nclassdef.mclass != null`
	private fun list_supertypes(nmodule: AModule, nclassdef: AClassdef,
			is_nominal_intro: Bool): Array[MClassType]
	do
		var mmodule = nmodule.mmodule.as(not null)
		var mclass = nclassdef.mclass.as(not null)
		var mclassdef = nclassdef.mclassdef
		var name = mclass.name
		var kind = mclass.kind

		var objectclass = try_get_mnominal_by_name(nmodule, mmodule, "Object")
		var pointerclass = try_get_mnominal_by_name(nmodule, mmodule, "Pointer")

		# Do we need to specify Object as a super class?
		var specobject = true

		# Do we need to specify Pointer as a super class? (is only valid
		# if `nclassdef` is an extern class)
		var specpointer = true

		var supertypes = new Array[MClassType]
		if nclassdef isa AStdClassdef then
			for nsc in nclassdef.n_superclasses do
				specobject = false
				var ntype = nsc.n_type
				var mtype = resolve_mtype_unchecked2(mmodule, mclass, mclassdef,
						ntype, false)
				if mtype == null then continue # Skip because of error
				if not mtype isa MClassType then
					error(ntype, "Error: supertypes cannot be a formal type.")
					continue
				end
				var superclass = mtype.mnominal
				if not kind.can_specialize(superclass.kind) then
					error(ntype, "Error: {kind} `{name}` cannot specialize {superclass.kind} `{superclass}`.")
				end
				supertypes.add mtype
				#print "new super : {mclass} < {mtype}"
				if superclass.kind == extern_kind then specpointer = false
			end
		end

		if is_nominal_intro and objectclass != null then
			if kind == extern_kind and name != "Pointer" then
				# it is an extern class, but not a Pointer
				if pointerclass == null then
					error(nclassdef, "Error: `Pointer` must be defined first.")
					return supertypes
				end
				if specpointer then supertypes.add pointerclass.mclass_type
			else if specobject then
				if name != "Object" then
					# it is a standard class without super class (but is not Object)
					supertypes.add objectclass.mclass_type
				else if kind != interface_kind then
					error(nclassdef, "Error: `Object` must be an {interface_kind}.")
				end
			end
		end

		return supertypes
	end

	# Undo side-effects of `list_supertypes`.
	private fun unresolve_supertypes(nclassdef: AClassdef)
	do
		if not nclassdef isa AStdClassdef then return
		for nsc in nclassdef.n_superclasses do
			nsc.n_type.clear_mtype
		end
	end

	# Check the validity of the specialization heirarchy
	private fun check_supertypes(nmodule: AModule, nclassdef: AClassdef)
	do
		var mmodule = nmodule.mmodule
		if mmodule == null then return
		var mclass = nclassdef.mclass
		if mclass == null then return
		var mclassdef = nclassdef.mclassdef
		if mclassdef == null then return

		for s in mclassdef.supertypes do
			if s.is_subtype(mmodule, mclassdef.bound_mtype, mclassdef.bound_mtype) then
				error(nclassdef, "Error: inheritance loop for class `{mclass}` with type `{s}`.")
			end
		end
	end

	# Build the classes of the module `nmodule`.
	private fun build_classes(nmodule: AModule)
	do
		# Force building recursively
		if nmodule.build_classes_is_done then return
		nmodule.build_classes_is_done = true
		var mmodule = nmodule.mmodule
		if mmodule == null then return
		for imp in mmodule.in_importation.direct_greaters do
			var nimp = mmodule2node(imp)
			if nimp != null then build_classes(nimp)
		end

		# Create all classes
		# process AStdClassdef before so that non-AStdClassdef classes can be attached to existing ones, if any
		for nclassdef in nmodule.n_classdefs do
			if not nclassdef isa AStdClassdef then continue
			self.build_a_mclass(nmodule, nclassdef)
		end
		for nclassdef in nmodule.n_classdefs do
			if nclassdef isa AStdClassdef then continue
			self.build_a_mclass(nmodule, nclassdef)
		end

		# Create all classdefs.
		# Process type subsets last so the introducing definition of a `MClass`
		# is always the first built.
		# Process `AStdClassdef`s before other definitions so that a
		# non-`AStdClassdef` definition can be attached to the `MClassDef`
		# built for the `AStdClassdef` node of the same class, if any.
		for nclassdef in nmodule.n_classdefs do
			if not nclassdef isa AStdClassdef then continue
			if nclassdef.mclass == null then continue
			if nclassdef.mclass.kind == subset_kind then continue
			self.build_a_mclassdef(nmodule, nclassdef)
		end
		for nclassdef in nmodule.n_classdefs do
			if nclassdef isa AStdClassdef then continue
			self.build_a_mclassdef(nmodule, nclassdef)
		end
		for nclassdef in nmodule.n_classdefs do
			if not nclassdef isa AStdClassdef then continue
			if nclassdef.mclass == null then continue
			if nclassdef.mclass.kind != subset_kind then continue
			self.build_a_mclassdef(nmodule, nclassdef)
		end

		# Create inheritance on all classdefs
		for nclassdef in nmodule.n_classdefs do
			self.collect_a_mclassdef_inheritance(nmodule, nclassdef)
		end

		# Create the mclassdef hierarchy
		for mclassdef in mmodule.mclassdefs do
			mclassdef.add_in_hierarchy
		end

		# Check inheritance
		for nclassdef in nmodule.n_classdefs do
			self.check_supertypes(nmodule, nclassdef)
		end

		# Check unchecked ntypes
		for nclassdef in nmodule.n_classdefs do
			if nclassdef isa AStdClassdef then
				var mclassdef = nclassdef.mclassdef
				# check bound of formal parameter
				for nfd in  nclassdef.n_formaldefs do
					var nfdt = nfd.n_type
					if nfdt != null and nfdt.mtype != null then
						var bound = resolve_mtype(mmodule, mclassdef, nfdt)
						if bound == null then return # Forward error
					end
				end
				# check declared super types
				for nsc in nclassdef.n_superclasses do
					var ntype = nsc.n_type
					if ntype.mtype != null then
						var mtype = resolve_mtype(mmodule, mclassdef, ntype)
						if mtype == null then return # Forward error
					end
				end
			end
		end

		# Check clash of ancestors
		for nclassdef in nmodule.n_classdefs do
			var mclassdef = nclassdef.mclassdef
			if mclassdef == null then continue
			var superclasses = new HashMap[MNominal, MClassType]
			for scd in mclassdef.in_hierarchy.greaters do
				for st in scd.supertypes do
					if not superclasses.has_key(st.mnominal) then
						superclasses[st.mnominal] = st
					else if superclasses[st.mnominal] != st then
						var st1 = superclasses[st.mnominal].resolve_for(mclassdef.mnominal.mclass_type, mclassdef.bound_mtype, mmodule, false)
						var st2 = st.resolve_for(mclassdef.mnominal.mclass_type, mclassdef.bound_mtype, mmodule, false)
						if st1 != st2 then
							error(nclassdef, "Error: incompatible ancestors for `{mclassdef.mnominal}`; conflict: `{st1}` and `{st2}`")
						end
					end
				end
			end
		end

		# TODO: Check that the super-class is not intrusive

		# Check that the superclasses are not already known (by transitivity)
		for nclassdef in nmodule.n_classdefs do
			if not nclassdef isa AStdClassdef or nclassdef.is_broken then continue
			var mclassdef = nclassdef.mclassdef
			if mclassdef == null then continue

			# Get the direct superclasses
			# Since we are a mclassdef, just look at the mclassdef hierarchy
			var parents = new Array[MNominal]
			for sup in mclassdef.in_hierarchy.direct_greaters do
				parents.add(sup.mnominal)
			end

			# Used to track duplicates of superclasses
			var seen_parents = new ArrayMap[MNominal, AType]

			# The Object class
			var objectclass = try_get_mnominal_by_name(nmodule, mmodule, "Object")

			# Check each declared superclass to see if it belong to the direct superclass
			for nsc in nclassdef.n_superclasses do
				var ntype = nsc.n_type
				var mtype = ntype.mtype
				if mtype == null then continue
				assert mtype isa MClassType
				var sc = mtype.mnominal
				if not parents.has(sc) or sc == objectclass then
					# Skip the warning on generated code
					if ntype.location.file != null and not ntype.location.file.filename.is_empty then
						warning(ntype, "useless-superclass", "Warning: superfluous super-class `{mtype}` in class `{mclassdef.mnominal}`.")
					end
				else if not seen_parents.has_key(sc) then
					seen_parents[sc] = ntype
				else
					warning(ntype, "useless-superclass", "Warning: duplicated super-class `{mtype}` in class `{mclassdef.mnominal}`.")
				end
			end
		end
	end

	# Registration of the nclassdef associated to each mclassdef
	private var mclassdef2nclassdef = new HashMap[MClassDef, AClassdef]

	# Retrieve the associated AST node of a mclassdef.
	#
	# This method is used to associate model entity with syntactic entities.
	# If the class definition is not associated with a node, returns `null`.
	fun mclassdef2node(mclassdef: MClassDef): nullable AClassdef do
		return mclassdef2nclassdef.get_or_null(mclassdef)
	end
end

redef class AModule
	# Flag that indicate if the class building is already completed
	var build_classes_is_done: Bool = false
	# What is the AClassdef associated to a `MNominal`?
	# Used to check multiple definition of a class.
	var mclass2nclassdef: Map[MNominal, AClassdef] = new HashMap[MNominal, AClassdef]
end

redef class AClassdef
	# The associated MClass once build by a `ModelBuilder`
	var mclass: nullable MNominal
	# The associated MClassDef once build by a `ModelBuilder`
	var mclassdef: nullable MClassDef
	# All (self and other) definitions for the same mclassdef
	var all_defs: nullable Array[AClassdef]
end

redef class AClasskind
	# The class kind associated with the AST node class
	private fun mkind: MClassKind is abstract
end
redef class AConcreteClasskind
	redef fun mkind do return concrete_kind
end
redef class AAbstractClasskind
	redef fun mkind do return abstract_kind
end
redef class AInterfaceClasskind
	redef fun mkind do return interface_kind
end
redef class AEnumClasskind
	redef fun mkind do return enum_kind
end
redef class AExternClasskind
	redef fun mkind do return extern_kind
end

redef class AFormaldef
	# The associated parameter type
	var mtype: nullable MParameterType = null

	# The associated bound
	var bound: nullable MType = null
end

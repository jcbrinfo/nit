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

# Injection of `isa` method definitions.
#
# TODO: Will become useless (and wrong) once the `subset` annotation is replaced
# by true method definitions.
module isa_method

import modelize_class

redef class ToolContext
	# The phase that injects `isa` method definitions.
	var isa_method_phase: Phase = new IsaMethodPhase(self, null)
end

private class IsaMethodPhase
	super Phase

	redef fun process_npropdef(npropdef: APropdef)
	do
		var v = new IsaMethodVisitor(self)
		v.enter_visit(npropdef)
	end
end

private class IsaMethodVisitor
	super Visitor

	var phase: Phase

	redef fun visit(node)
	do
		node.accept_isa_method_visitor(self)
	end

	# Process a `subset` annotation.
	fun visit_subset_annotation(node: AAnnotPropdef)
	do
		# Check if the annotation defines a membership test.
		var number_of_args = node.n_args.length
		if number_of_args != 1 then
			if number_of_args > 1 then
				phase.toolcontext.error(node.location,
					"Error: {number_of_args} arguments specified for the " +
					"`subset` annotation; at most 1 expected."
				)
			end
			return
		end

		var n_id = node.n_atid.n_id
		var class_def = node.parent.as(AClassdef)

		# Add a definition of the `isa` method with the same body than the
		# annotation.

		var method_def = new AMethPropdef
		method_def.location = node.location
		method_def.n_doc = node.n_doc
		method_def.n_kwredef = node.n_kwredef
		method_def.n_annotations = node.n_annotations
		method_def.n_block = node.n_args.first
		method_def.n_kwisa = new TKwisa.init_tk(n_id.location)
		if node.n_visibility != null then
			method_def.n_visibility = node.n_visibility
		end

		class_def.n_propdefs.add(method_def)
	end
end

redef class ANode
	private fun accept_isa_method_visitor(v: IsaMethodVisitor) do end
end

redef class AAnnotPropdef
	redef fun accept_isa_method_visitor(v)
	do
		if n_atid.n_id.text == "subset" then
			v.visit_subset_annotation(self)
		end
	end
end



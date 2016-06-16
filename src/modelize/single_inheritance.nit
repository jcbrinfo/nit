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

# Enforces single inheritance for class kinds where multiple inheritance is prohibited.
#
# SEE: `MClassKind.single_inheritance`
module single_inheritance

intrude import modelize_class
private import annotation

redef class ToolContext
	var single_inheritance_phase: Phase = new ModelizePropertyPhase(self, [modelize_class_phase])
end

# Enforces single inheritance for class kinds where multiple inheritance is prohibited.
#
# SEE: `MClassKind.single_inheritance`
private class SingleInheritancePhase
	super Phase

	redef fun process_nclassdef(nclassdef)
	do
		if not nclassdef isa AStdClassdef then return

		var mclassdef = nclassdef.mclassdef
		if mclassdef == null then return
		var mclass = mclassdef.mclass

		# We only need to do this once per class
		if not mclassdef.is_intro then return

		if mclass.kind != extern_kind then return

		#TODO
	end
end

redef class ModelBuilder
	#TODO
end

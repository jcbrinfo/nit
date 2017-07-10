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

import core::kernel

# Test of predicate definitions

subset NonZero
	super Numeric
	isa do return not is_zero #alt1-8#
	#alt1#                                  # Predicate undefined. Must be allowed.
	#alt2# isa do return my_isa             # Forbidden method call
	#alt3# isa do return 42                 # Return type mismatch
	#alt4# private isa do return true       # Invalid visibility
	#alt5# isa(x: Int) do return true       # Too much arguments, missing return type (or syntax error)
	#alt6# isa(x: Int): Bool do return true # Too much arguments (or syntax error)
	#alt7# isa: Int do return 42            # Invalid return type (or syntax error)

	#alt8# isa do                           # Same as `alt2`, but indirect
		#alt8# var me = self
		#alt8# return not me.my_isa
	#alt8# end

	# Being specific to the subset, this method should not be callable from the
	# membership test.
	fun my_isa: Bool do return not is_zero
end

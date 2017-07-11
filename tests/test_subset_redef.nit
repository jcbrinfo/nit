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

# Test of forbidden overriding and duplicate subset definitions.
#
# TODO: For tests of subset refinements, see `test_subset_redef2`

import core::kernel

subset NonZero
	isa do return not self.is_zero
	super Numeric

	fun int_inverse: Int do
		return (1.0 / self.to_f).to_i
	end

	#alt1# redef fun zero do return super
	#alt2# redef isa do return true
	#alt3# redef type OTHER: Int
end

#alt4# redef class NonZero end

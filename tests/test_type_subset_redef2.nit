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

import test_type_subset_redef

redef class NonZero
	subset do return (not self isa Float or self == self * 1.0) and super
	#alt1# super Numeric
	#alt2# super Int

	redef fun int_inverse: Int do
		if self isa Int then
			return super - 1
		else
			return super
		end
	end

	#alt3# fun something do end
	#alt4# redef fun zero do return super
end

var x: nullable Object

x = 0.5 #alt5# x = 0 #alt6# x = 0.0 #alt7# x = 0.0 / 0.0
assert x isa NonZero
assert x.int_inverse == 2

x = 2
assert x isa NonZero
assert x.int_inverse == -1

x = 1.0 / 0.0
assert x isa NonZero
assert x.int_inverse == 0

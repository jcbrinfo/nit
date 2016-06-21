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

# If the supertype is not specified in a "redef" (or it is the original base
# class of the subset), a regular refinement is done on the main definition.

redef class NonZero
	subset do return not self.is_zero
	#alt1# super Numeric
end

# If the supertype is specified in a "redef", a specialization of the subset is
# created if it not already exists.

redef class NonZero
	subset do return self == self and super
	super Float #alt2# super Object
end

# If the specialization already exists, it will be refined.

redef class NonZero
	super Int

	redef fun int_inverse: Int do
		return super - 1
	end

	#alt3# fun something do return 0
	#alt4# redef fun abs do return super
end

# Only the root specialization can have a subset as its supertype.

class Positive
	super Numeric
	subset do return self >= self.zero
end
#alt5# redef class NonZero of Positive end

var x: NonZero

x = 0.5 #alt6# x = 0 #alt7# x = 0.0 #alt8# x = 0.0 / 0.0
assert x.int_inverse == 2

x = 2
assert x.int_inverse == -2

x = 1.0 / 0.0
assert x.int_inverse == 0

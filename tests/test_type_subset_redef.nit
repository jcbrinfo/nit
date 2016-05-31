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

import kernel

class NonZero
	is subset
	super Numeric

	fun int_inverse: Int do
		return (1 / self).to_i
	end
end

# If the supertype is not specified in a "redef", a regular refinement is done.

redef class NonZero
	is subset do return not self.is_zero
	#alt1# super Numeric
end

# If the supertype is specified in a "redef", a specialization of the subset is
# created.

redef class NonZero
	is subset do return self == self and super
	super Float #alt2# super Object
end

redef class NonZero
	super Int

	redef fun int_inverse: Int do
		print("Already an Int.")
		return 0
	end

	#alt3# fun something do return 0
	#alt4# redef fun rand do return 0
end

var x: NonZero

x = 0.5 #alt5# x = 0 #alt6# 0.0 #alt7# 0.0 / 0.0
print(x.int_inverse)

x = 2
print(x.int_inverse)

x = 1.0 / 0.0
print(x.int_inverse)

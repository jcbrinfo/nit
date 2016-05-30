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

subset NonZero of Numeric
	isa do return not self.is_zero

	fun int_inverse: Int do
		return (1 / self).to_i
	end
end

redef subset NonZero of Float
	isa do return self == self and super
end

redef subset NonZero of Int

	redef fun int_inverse: Int do
		print("Already an Int.")
		return 0
	end

	#alt1 fun something do return 0
end

var x: NonZero

x = 0.5 #alt2 x = 0 #alt3 0.0 #alt4 0.0 / 0.0
print(x.int_inverse)

x = 2
print(x.int_inverse)

x = 1.0 / 0.0
print(x.int_inverse)
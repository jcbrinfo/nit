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

subset Natural of Int
	isa do return self >= 0

	fun fib: Natural do
		if self < 2 then return self
		return (self - 1).as(Natural).fib + (self - 2).as(Natural).fib
	end
end

subset Bool2 of Int
	new (x: Int) do return x #alt2 init (x: Int) do end
	isa do return self == 0 or self == 1

	fun is_true do return self == 1
	#alt4 var foo: Int
end

var x: Natural = 3 #alt1 var x: Natural = -1
print(x.fib)

var y = Bool(1) #alt3 var y = Bool(-1)
print(y.is_true)

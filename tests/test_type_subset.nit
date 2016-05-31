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

# TODO Proposed syntax:
#subset Natural of Int
#	isa do return self >= 0
#	…
#end

class Natural
	super Int
	#alt1# super Numeric
	subset do return self >= 0

	fun fib: Natural do
		if self < 2 then return self
		return (self - 1).as(Natural).fib + (self - 2).as(Natural).fib
	end
end

class Bool2
	super Int
	subset do return self == 0 or self == 1
	new (x: Int) do return x

	fun is_true do return self == 1
end

var x: Natural = 3 #alt2# var x: Natural = -1 #alt3# var x: Natural = 1.0
print(x.fib)

var y = new Bool2(1) #alt4# var y = new Bool2(-1)
print(y.is_true)

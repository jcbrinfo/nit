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

import core

class Natural #alt1# class Natural[BOOM]
	super Int
	subset do return self >= 0

	fun fib: Natural do
		if self < 2 then return self
		return (self - 1).as(Natural).fib + (self - 2).as(Natural).fib
	end
end

class Summable[E: Numeric]
	super Sequence[E]
	subset do return true

	fun sum: E do
		total = zero
		for x in self do total += x
		return total
	end

	fun zero is abstract
end

redef class Summable[E: Natural]
	super Sequence[E] #alt2# super Bytes #alt3# super Range[E]

	redef fun zero do return 0
end

var arr: Array[Natural] = [0, 1, 2, 3]
for x in arr do print(x.fib)
print(arr.as(Summable).sum)

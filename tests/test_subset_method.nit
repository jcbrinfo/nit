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

subset Natural
	super Int
	isa do return self >= 0

	fun test_fib: Natural do
		if self < 2 then return self
		var a = (self - 1).as(Natural).test_fib
		var b = (self - 2).as(Natural).test_fib
		return (a + b).as(Natural)
	end
end

var x = 4 #alt1# var x = -1
assert x isa Natural #alt1#
assert x.test_fib == 3

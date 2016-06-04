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

# TODO: alt1: An ordinary class that redefines the membership test.

class Natural
	super Int
	#alt2# super Numeric
	subset do return self >= 0 #alt3# subset #alt4# subset do return 42

	#alt5# init (x: Int) do end
	#alt6# var foo: Int
	#alt7# redef fun abs do return super
	#alt8# subset # The annotation can not be specified twice.

	fun fib: Natural do
		if self < 2 then return self
		return (self - 1).as(Natural).fib + (self - 2).as(Natural).fib
	end
end

var x: Natural = 0
assert x.fib == 1

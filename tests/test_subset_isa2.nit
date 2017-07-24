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

# Test of type tests over subsets.
#
# Ensure that both the base class and the predicate are considered.

subset Natural
	super Int
	isa do return self >= 0 #alt1#
	#alt1# # Predicate undefined. Must be equivalent to `isa do return true`
end

assert 42 isa Natural
assert not -1 isa Natural #alt1# assert -1 isa Natural
assert not 1.0 isa Natural

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

# Test of the modeling of generic subsets.
#
# Ensures that the constraints regarding the type signature (no parameter
# introduction, no fixing) are enforced.
#
# * `alt1`: A parameter is not linked to the base type.
# * `alt2`: Use of a subset as a bound. Must be allowed.
# * `alt3`: The type signature must be explicited.
# * `alt4`: Same as `alt3`, but with a type argument fixed by the subset.
# * `alt5`: Type argument fixed by the subset.
# * `alt6`: Type argument fixed by the subset (more trivial case).
# * `alt7`: Too general bound.
# * `alt8`: Parameter not linked to the base type, even if the base type has a
#   generic supertype. Ensures that only the direct supertype is considered.
# * `alt9`: A parameter is not linked to the base type, even if the base type
#   has the same arity than the subset.

import core::kernel

interface Foo[E]
end

interface Foo2[K, V]
end

class DiscreteFoo[E: Discrete]
	super Foo[E]
end

class ByteFoo
	super Foo[Byte]
end

subset Natural #alt1# subset Natural[BOOM]
	super Int
end

subset Bar[E: Int] #alt2-5,7#
#alt2# subset Bar[E: Natural]
#alt3,4# subset Bar
#alt5,7# subset Bar[E]
	super Foo[E] #alt4-8#
	#alt4,5,6# super Foo[Int]
	#alt7# super DiscreteFoo[E]
	#alt8# super ByteFoo
end

subset Bar2[K: Float, V: Bool]
	super Foo2[K, V] #alt9#
	#alt9# super Foo2[K, K]
end

subset Baz[T]
	super Foo[T]
end

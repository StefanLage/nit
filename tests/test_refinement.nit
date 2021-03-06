# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2004-2008 Jean Privat <jean@pryen.org>
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


redef class Int
    fun fact0: Int
	do
	    return fact(1)
	end
    fun fact(r: Int): Int
	do
	    if self <= 1 then
		return r
	    else
		return (self-1).fact(r*self)
	    end

	end

    fun fact2: Int
	do
	    var r = 1
	    var i = self
	    while i > 0 do
		r = r * i
		i = i - 1
	    end
	    return r
	end
end

redef class Array[F]
    redef fun add(item: F)
	do
	    self[length] = item
	    self[length] = item
	end
end

redef class Object
    redef fun printn(a: Object...)
	do
            stdout.write("print:")
	    stdout.write(a.to_s)
	end
end

printn("4! = ")
print(4.fact2)
printn("4! = ")
print(4.fact0)

var a = [1,2]
do
    print(a)
    a.add(3)
    print(a)
end

var b = new Buffer.from("ab")
do
    print(b)
    b.add('c')
    print(b)
end

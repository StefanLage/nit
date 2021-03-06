# This file is part of NIT ( http://www.nitlanguage.org ).
#
# Copyright 2012 Jean Privat <jean@pryen.org>
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

# Metrics about the usage of explicit and implicit self
module self_metrics

import modelbuilder
private import metrics_base

private class ASelfVisitor
	super Visitor
	var total: Int = 0
	var implicits: Int = 0

	redef fun visit(n)
	do
		if n isa ASelfExpr then
			self.total += 1
			if n isa AImplicitSelfExpr then
				self.implicits += 1
			end
		end
		n.visit_all(self)
	end
end

# Visit the AST and print metics about the usage of self.
fun compute_self_metrics(modelbuilder: ModelBuilder)
do
	print "--- Explicit vs. Implicit Self ---"
	# Visit all the source code to collect data
	var visitor = new ASelfVisitor
	for nmodule in modelbuilder.nmodules do
		for nclassdef in nmodule.n_classdefs do
			visitor.enter_visit(nclassdef)
		end
	end
	print "Total number of self: {visitor.total}"
	print "Total number of implicit self: {visitor.implicits} ({div(visitor.implicits*100,visitor.total)}%)"
end

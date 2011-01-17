#--
# Copyleft shura. [shura1991@gmail.com]
#
# This file is part of codice_fiscale.
#
# codice_fiscale is free software: you can redistribute it and/or modify 
# it under the terms of the GNU Affero General Public License as published
# by the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# codice_fiscale is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with codice_fiscale. If not, see <http://www.gnu.org/licenses/>.
#++

Gem::Specification.new do |g|
  g.name          = 'codice_fiscale'
  g.version       = '0.1'
  g.author        = 'shura'
  g.email         = 'shura1991@gmail.com'
  g.homepage      = 'http://github.com/shurizzle/ruby-codice_fiscale'
  g.platform      = Gem::Platform::RUBY
  g.description   = 'Codice fiscale library'
  g.summary       = 'Tiny library to make easy working with codice fiscale'
  g.files         = Dir['lib/**/*']
  g.require_path  = 'lib'
  g.executables   = [ ]
end

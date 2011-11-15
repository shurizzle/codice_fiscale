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

begin
  require 'codice_fiscale'
rescue LoadError
  $:.unshift File.realpath(File.join(File.dirname(__FILE__), '..', 'lib'))
  retry
end

#cf = CodiceFiscale.new(name: 'Mario', surname: 'Rossi', bplace: 'Milano (MI)')
cf = CodiceFiscale.new(name: 'Gelsomino', surname: 'Rossi', bplace: 'Milano (MI)')
cf.bday = Time.new(1950, 4, 1)
cf.gender = 'male'


puts <<CODICEFISCALE
COGNOME:  ROSSI
NOME:     Mario
NATO A:   Milano (MI)
GIORNO:   01/04/1950      SESSO: M

CODICE FISCALE:
#{cf.to_s(' ')}

CODICE FISCALE ALTERNATIVO:
#{cf.alternative(1, ' ')}
CODICEFISCALE

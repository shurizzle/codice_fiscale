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

class CodiceFiscale < String
  VERSION = '0.1'

  MONTH = [nil, ?A, ?B, ?C, ?D, ?E, ?H, ?L, ?M, ?P, ?R, ?S, ?T]

  ALFANUM_TO_CODE = {
    odd: {
           ?0 => 1, ?1 => 0, ?2 => 5, ?3 => 7, ?4 => 9,
           ?5 => 13, ?6 => 15, ?7 => 17, ?8 => 19, ?9 => 21,
           ?A => 1, ?B => 0, ?C => 5, ?D => 7, ?E => 9,
           ?F => 13, ?G => 15, ?H => 17, ?I => 19, ?J => 21,
           ?K => 2, ?L => 4, ?M => 18, ?N => 20, ?O => 11,
           ?P => 3, ?Q => 6, ?R => 8, ?S => 12, ?T => 14,
           ?U => 16, ?V => 10, ?W => 22, ?X => 25,
           ?Y => 24, ?Z => 23
         },
    even: {
            ?0 => 0, ?1 => 1, ?2 => 2, ?3 => 3, ?4 => 4,
            ?5 => 5, ?6 => 6, ?7 => 7, ?8 => 8, ?9 => 9,
            ?A => 0, ?B => 1, ?C => 2, ?D => 3, ?E => 4,
            ?F => 5, ?G => 6, ?H => 7, ?I => 8, ?J => 9,
            ?K => 10, ?L => 11, ?M => 12, ?N => 13, ?O => 14,
            ?P => 15, ?Q => 16, ?R => 17, ?S => 18, ?T => 19,
            ?U => 20, ?V => 21, ?W => 22, ?X => 23, ?Y => 24,
            ?Z => 25
          }
  }

  ALTERNATIVE = {
    ?0 => ?L, ?1 => ?M, ?2 => ?N, ?3 => ?P, ?4 => ?Q,
    ?5 => ?R, ?6 => ?S, ?7 => ?T, ?8 => ?U, ?9 => ?V,
    0 => ?L, 1 => ?M, 2 => ?N, 3 => ?P, 4 => ?Q,
    5 => ?R, 6 => ?S, 7 => ?T, 8 => ?U, 9 => ?V
  }

  DBDIR = File.realpath(File.join(File.dirname(__FILE__), 'db'))

  attr_reader :name, :surname, :bday, :bplace, :gender

  def name?
    !!@name
  end

  def surname?
    !!@surname
  end

  def bday?
    !!@bday
  end

  def bplace?
    !!@bplace
  end

  def gender?
    !!@gender
  end

  def data?
    self.name? and self.surname? and self.bday? and self.bplace? and self.gender?
  end

  def name=(n)
    @name = n.upcase if n.is_a?(String) and n =~ /^[A-Z]+$/i

    generate_code!
  end

  def surname=(s)
    @surname = s.upcase if s.is_a?(String) and s =~ /^[A-Z]+$/i

    generate_code!
  end

  def bday=(day)
    @bday = case day
      when Time
        {
          day: day.day,
          mon: day.mon,
          year: day.year.to_s[-2, 2].to_i
        }
      when String
        self.bday = Time.new($4, $3, $1) if day =~ /^(\d{1,2})([^\dA-Z])(\d{1,2})\2(\d{2}||\d{4})$/i
        @bday
      else @bday
    end

    generate_code!
  end

  def bplace=(place)
    return unless place.is_a?(String)
    place.strip!
    place.upcase!
    if place =~ /^([A-Z']+\s*)+(?:\(([A-Z]{2})\))?$/
      @bplace = {
        city: $1.strip,
        prov: $2
      }
    end

    generate_code!
  end

  def gender=(gen)
    if gen == :M or gen == :m or gen =~ /^m(ale)?$/i
      @gender = :M
    elsif gen == :F or gen == :f or gen =~ /^f(emale)?$/i
      @gender = :F
    end

    generate_code!
  end

  def initialize(options = {})
    self.name = options[:name]
    self.surname = options[:surname]
    self.bday = options[:bday]
    self.bplace = options[:bplace]
    self.gender = options[:gender]
  end

  def generate_code!
    return unless self.data?
    code = ""

    # TRIPLET FOR SURNAME
    code << (self.surname.scan(/[^AEIOU]/).join + self.surname.scan(/[AEIOU]/).join)[0, 3].ljust(3, 'X')

    # TRIPLET FOR NAME
    cons = self.name.scan(/[^AEIOU]/).join
    cons << cons[1] && cons[1] = '' if cons.size > 3
    code << (cons + self.name.scan(/[AEIOU]/).join)[0, 3].ljust(3, 'X')

    # QUINTET FOR BDAY AND GENDER
    code << self.bday[:year].to_s.rjust(2, '0')
    code << CodiceFiscale::MONTH[self.bday[:mon]]
    code << (self.bday[:day] + (self.gender == :F ? 40 : 0)).to_s.rjust(2, '0')

    # QUARTET FOR BPLACE
    code << self.belfiore_code(self.bplace[:city], self.bplace[:prov])
    
    # CONTROL CODE
    sum = 0
    code.split(//).each_with_index {|ch, i|
      sum += ALFANUM_TO_CODE[i.odd? ? :even : :odd][ch]
    }
    code << ((sum % 26) + 65).chr

    self.replace(code)
  end

  def belfiore_code(city, province = nil)
    code = nil
    File.open(File.join(DBDIR, (province and province == 'EE' ? 'ee.db' : "#{city[0].downcase}.db"))) {|f|
      f.each_line {|line|
        co, c, p = line.strip.split(';')
        code = co.dup and break if c == city and (province and province != 'EE' ? p == province : true)
      }
    }

    code
  end

  def alternative(level = 1)
    code = self.dup
    code.scan(/[0-9]/).reverse[0, level].each {|n|
      i = code.rindex(n)
      code[i] = ALTERNATIVE[code[i]]
    }

    code
  end

  def alternative!(level = 1)
    self.replace(self.alternative(level))
  end
end

--
-- FPGA Cores -- An HDL core library
--
-- Copyright 2014-2016 by Andre Souto (suoto)
--
-- This file is part of FPGA Cores.
-- 
-- FPGA Cores is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
-- 
-- FPGA Cores is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with FPGA Cores.  If not, see <http://www.gnu.org/licenses/>.

use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.math_real.all;

package common_pkg is

  type integer_array_t is array (natural range <>) of integer;
  type integer_2d_array_t is array (natural range <>) of integer_array_t;

  -- Calculates the number of bits required to represent a given value
  function numbits (constant v : natural) return natural;

  -- Add double quotes around a string
  function quote ( constant s : string ) return string;
  function quote ( constant s : character ) return string;

  -- Gray <-> Binary conversion
  function bin_to_gray (bin  : std_logic_vector) return std_logic_vector;
  function bin_to_gray (bin  : unsigned) return unsigned;
  function gray_to_bin (gray : std_logic_vector) return std_logic_vector;
  function gray_to_bin (gray : unsigned) return unsigned;

  function mirror_bytes (constant v : std_logic_vector) return std_logic_vector;
  function mirror_bits (constant v : std_logic_vector) return std_logic_vector;

  function minimum(constant a, b : integer) return integer;
  function minimum(constant values : integer_array_t) return integer;
  function to_boolean( v : std_ulogic) return boolean;

  function max (constant a, b : integer) return integer;
  function max (constant v : integer_array_t) return integer;

  function sum (constant v : integer_array_t) return integer;

end common_pkg;

package body common_pkg is

  ------------------------------------------------------------------------------------
  -- Calculates the number of bits required to represent a given value
  function numbits ( constant v : natural ) return natural is
  begin
    if v <= 1 then
      return 1;
    end if;

    return integer(ceil(log2(real(v))));
  end function numbits;

  ------------------------------------------------------------------------------------
  function mirror_bytes (
      constant v           : std_logic_vector)
  return std_logic_vector is
      constant byte_number : natural := v'length / 8;
      variable result      : std_logic_vector(v'range);
  begin
      assert byte_number * 8 = v'length
          report "Can't swap bytes with a non-integer number of bytes. " &
                 "Argument has " & integer'image(v'length)
          severity Failure;

      for byte in 0 to byte_number - 1 loop
          result((byte_number - byte) * 8 - 1 downto (byte_number - byte - 1) * 8) := v((byte + 1) * 8 - 1 downto byte * 8);
      end loop;
      return result;
  end function mirror_bytes;

  ------------------------------------------------------------------------------------
  function mirror_bits (constant v : std_logic_vector) return std_logic_vector is
    variable result : std_logic_vector(v'length - 1 downto 0);
  begin

    for i in 0 to v'length - 1 loop
      result(v'length - i - 1) := v(i + v'low);
    end loop;

    return result;
  end;

  ------------------------------------------------------------------------------------
  function minimum(constant a, b : integer) return integer is
  begin
    return minimum(integer_array_t'(a, b));
  end;

  ------------------------------------------------------------------------------------
  function minimum(constant values : integer_array_t) return integer is
    variable result : integer;
  begin
    for index in values'range loop

      if values(index) < result then
        result := values(index);
      end if;

    end loop;

    return result;
  end;

  --------------------------------------------------------------------------------------
  function to_boolean( v : std_ulogic) return boolean is begin
    case v is
      when '0' | 'L'   => return (false);
      when '1' | 'H'   => return (true);
      when others      => return (false);
    end case;
  end to_boolean;

  --------------------------------------------------------------------------------------
  function max (constant a, b : integer) return integer is
  begin
    return max((a, b));
  end;

  --------------------------------------------------------------------------------------
  function max (constant v : integer_array_t) return integer is
    variable result : integer := 0;
  begin
    for i in v'range loop
      if v(i) > result then
        result := v(i);
      end if;
    end loop;
    return result;
  end;

  --------------------------------------------------------------------------------------
  function sum (constant v : integer_array_t) return integer is
    variable sum : natural;
  begin
    for i in v'range loop
      sum := sum + v(i);
    end loop;

    return sum;
  end;

  --------------------------------------------------------------------------------------
  -- Gray <-> Binary conversion
  function bin_to_gray (
               bin  : std_logic_vector) return std_logic_vector is
      variable gray : std_logic_vector(bin'range);
  begin
      gray(gray'high) := bin(bin'high);
      for i in bin'high - 1 downto 0 loop
          gray(i) := bin(i + 1) xor bin(i);
      end loop;
      return gray;
  end function bin_to_gray;

  --------------------------------------------------------------------------------------
  function gray_to_bin (
               gray : std_logic_vector) return std_logic_vector is
      variable bin  : std_logic_vector(gray'range);
  begin
      bin(bin'high) := gray(gray'high);
      for i in gray'high - 1 downto 0 loop
          bin(i) := bin(i + 1) xor gray(i);
      end loop;
      return bin;
  end function gray_to_bin;

  --------------------------------------------------------------------------------------
  function bin_to_gray (bin  : unsigned) return unsigned is
  begin
      return unsigned(bin_to_gray(std_logic_vector(bin)));
  end bin_to_gray;

  --------------------------------------------------------------------------------------
  function gray_to_bin (gray : unsigned) return unsigned is
  begin
      return unsigned(gray_to_bin(std_logic_vector(gray)));
  end gray_to_bin;

  --------------------------------------------------------------------------------------
  -- Add double quotes around a string
  function quote ( constant s : character ) return string is
  begin
    return '"' & s & '"';
  end;

  --------------------------------------------------------------------------------------
  function quote ( constant s : string ) return string is
  begin
    return '"' & s & '"';
  end function quote;

end package body;

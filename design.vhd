-- Simple contador gate design
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ControleElevador is
	port(
    	clk: in std_logic;
		s0, s1, s2, s3: in std_logic; --- sensores 
        b0, b1, b2, b3: in std_logic; --- botoes de chamada        
        ch0: out std_logic:='0';
        ch1: out std_logic:='0';
        ch2: out std_logic:='0';
        ch3: out std_logic:='0';
        sobe: out std_logic:='0';
        desce: out std_logic:='0');        	
end;

architecture ark of ControleElevador is
SIGNAL posiAgr: INTEGER RANGE 0 TO 10;
SIGNAL destino: INTEGER:=0;
SIGNAL eleS: std_logic_vector(1 downto 0):="00";
SIGNAL Ts: std_logic:='0';
begin
----Maquina Estado ELevador---------------------------------
 	MaqELe: process(clk)
    VARIABLE cheguei: std_logic:='0';
    begin
    	--if falling_edge(clk) then
        if falling_edge(clk) then
        	case eleS is 
            when "00"=> --no destino ou parado
            	if(posiAgr = destino) then
                	--cheguei = 0 --ESPERA
            	elsif((destino < posiAgr) and destino > 0 ) then
                	eleS <= "01"; --desce
                elsif((destino > posiAgr) and destino > 0) then
                	eleS<="10";  --sobe
                else
                	eleS<="00";
                end if;
             when "01"=> --descendo
             	if(destino < posiAgr) then
                	eleS <= "01";
                elsif(posiAgr = destino) then
                 	eleS<="11";
                    --cheguei = 1;
                 end if;
             when "10"=> --subindo
             	if(destino > posiAgr) then
                	eleS <= "10";
                elsif(posiAgr = destino) then
                 	--eleS<="00";
                    eleS<="11";
                    --cheguei = 1;
                 end if;
              when "11"=> --espera
              		if(Ts = '0') then
                    	eleS<="00";
                    end if;
              when others => eleS <= "00";
              end case;
            end if;
     end process;

---------------------------------------------

--Maquina estado CONTADOR-----------------------------------
	contador: process(clk, eleS)
    VARIABLE time: INTEGER RANGE 0 TO 31;
    --VARIABLE Ts: std_logic:='0';
    --VARIABLE stop: std_logic:='0';
    begin	
    	if rising_edge(clk) then
          case Ts is
          when '0' => --estado parado
              if(eleS = "11") then 
              	Ts<='1';   						
              else 
              	Ts<='0'; 
              end if;
          when '1' => --estado contando
              if (time=29) then 				
                  --stop<='0';
                  time:=0;
                  Ts<='0';
              else
                  time:=time+1;				
              end if;
            when others => Ts<='0';
        	end case;
    	end if;
    end process;
    ----------------------------------------------
    
    
    --Atualiza Lista------------------------------
    Uplista: process(b0, b1, b2, b3, clk)
     type INT_ARRAY is array (0 to 30) of integer;
     VARIABLE my_array: INT_ARRAY;
     --VARIABLE last: INTEGER RANGE 0 TO 10:=0;
     VARIABLE size: INTEGER:=0;
     begin
     	if falling_edge(b0) and (ch0='0') then
        	my_array(size):= 1;
            --ch0<='1';
            size:= size +1;
        end if;
        if falling_edge(b1) and (ch1='0') then
        	my_array(size):= 2;
            --ch1<='1';
            size:= size +1;
        end if;    
         if falling_edge(b2) and (ch2='0') then
        	my_array(size):= 3;
            size:= size +1;
        end if;
         if falling_edge(b3) and (ch3='0') then
        	my_array(size):= 4;
            size:= size +1;
        end if;
        if(posiAgr = destino) then
        	if(size > 0) then
            	destino<=my_array(0);
                --SizeTest<=size;
            end if;
            if(size > 1) then
            	for i  in 0 to size-1 loop
            		my_array(i):= my_array(i+1);
            	end loop;
              size:= size-1;
            end if;
         end if;
         if(size = 0) then
         	destino<=posiAgr;
         end if;
     end process;
     -------------------------------------------------------
     
     
     --Atualiza Posição--------------------------------------
     Upposi: process(s0,s1,s2,s3, clk)
     begin
     	if (s0 = '0') then
        	posiAgr<= 1;
        elsif (s1 = '0') then
        	posiAgr<= 2;    
        elsif (s2 = '0') then
        	posiAgr<= 3;
        elsif (s3 = '0') then
        	posiAgr<= 4;
        end if;
     end process;
     -----------------------------------------------------------
    --LED1
    Mled1: process(b0, Ts)
    begin
    	if falling_edge(b0) then
        	ch0<='1';
       	end if;
        if rising_edge(Ts) then
        	if (posiAgr = 1) then
            	ch0<='0';
        	end if;
        end if;
    end process;
    ------
    --LED2---
      Mled2: process(b1, Ts)
    begin
    	if falling_edge(b1) then
        	ch1<='1';
       	end if;
        if rising_edge(Ts) then
        	if (posiAgr = 2) then
            	ch1<='0';
        	end if;
        end if;
    end process;
    -------------
    ---LED3------
       Mled3: process(b2, Ts)
    begin
    	if falling_edge(b2) then
        	ch2<='1';
       	end if;
        if rising_edge(Ts) then
        	if (posiAgr = 3) then
            	ch2<='0';
        	end if;
        end if;
    end process;
    -----------
    
    ----LED4---
       Mled4: process(b3, Ts)
    begin
    	if falling_edge(b3) then
        	ch3<='1';
       	end if;
        if rising_edge(Ts) then
        	if (posiAgr = 4) then
            	ch3<='0';
        	end if;
        end if;
    end process;
    -------------
    ------Saidas Sobe desce ----------------------
     with eleS select sobe <= -- lógica da saída
    '1' when "10",
	'0' when others;
    
    with eleS select desce <= -- lógica da saída
    '1' when "01",
	'0' when others;
    -----------------------------------------------
    
end ark;
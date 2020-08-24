-- Testbench para o elevador de 4 andares - Rafael P. Vivacqua
library IEEE;
use IEEE.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity testbench is
-- empty
end testbench; 

architecture tb of testbench is

component ControleElevador is
port( 
    clk: in std_logic;
    s0, s1, s2, s3: in std_logic;     --- sensores de andar
    b0, b1, b2, b3: in std_logic;     --- botoes de chamada
    ch0, ch1, ch2, ch3: out std_logic; --- registro de chamada
    sobe, desce: out std_logic  );
end component;

signal clk: std_logic;
signal s0, s1, s2, s3: std_logic;     --- sensores de andar
signal b0, b1, b2, b3: std_logic;     --- botoes de chamada
signal ch0, ch1, ch2, ch3: std_logic; --- registro de cham
signal sobe, desce: std_logic;

-- variavel de estado interna: posição da cabine virtual de elevador
signal AA_Aux: std_logic_vector(8 downto 0):="000000000";  -- começa no terreo

begin

-- liga o testbench ao controlador em teste
DUT1: ControleElevador port map(clk, s0, s1, s2, s3, b0, b1, b2, b3, ch0, ch1, ch2, ch3, sobe, desce);

-- logica interna para emular os sensores de andar
s0 <= '0' when AA_Aux(8 downto 3) = "000000" else '1';
s1 <= '0' when AA_Aux(8 downto 3) = "010000" else '1';
s2 <= '0' when AA_Aux(8 downto 3) = "100000" else '1';
s3 <= '0' when AA_Aux(8 downto 3) = "110000" else '1';


-- gerador do clock (1kHz)
process begin
    for jj in 0 to 2000 loop
    	clk <= '0';  wait for 0.5 ms;
        
        if(sobe = '1') then AA_Aux <= AA_Aux + 1; end if;        
        if(desce = '1') then AA_Aux <= AA_Aux - 1; end if;         

    	clk <= '1';  wait for 0.5 ms;
	end loop;
wait;
end process;


-- gerador das chamadas
process begin
-- estado inicial
b0 <= '1'; b1 <= '1'; b2 <= '1'; b3 <= '1';



--- COLOCAR AQUI A SEQUENCIA DE CHAMADAS DESEJADA
wait for 30 ms;   
b1 <= '0'; wait for 1 ms; b1 <= '1';
wait for 60 ms;
b0 <= '0'; wait for 1 ms; b0 <= '1';
b3 <= '0'; wait for 1 ms; b3 <= '1';
wait for 20 ms;
b3 <= '0'; wait for 1 ms; b3 <= '1';
wait for 10 ms;
b2 <= '0'; wait for 1 ms; b2 <= '1';
wait for 400 ms;
b3 <= '0'; wait for 1 ms; b3 <= '1';
wait for 50 ms;
b2 <= '0'; wait for 1 ms; b2 <= '1';
wait for 50 ms;
b1 <= '0'; wait for 1 ms; b1 <= '1';
wait for 100 ms;
b0 <= '0'; wait for 1 ms; b0 <= '1';





wait;
end process;


end tb;

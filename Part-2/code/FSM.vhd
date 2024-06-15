library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;
use work.register_pkg1.all;

entity FSM is
Port (
    clock: in std_logic;
    reset: in std_logic;
    HSYNC: out std_logic;
    VSYNC: out std_logic;
    vgaRed: out std_logic_vector(3 downto 0);
    vgaBlue: out std_logic_vector(3 downto 0);
    vgaGreen: out std_logic_vector(3 downto 0)
    );
end FSM;

architecture Behavioral of FSM is

--VGA Signals and Constants

signal RST: std_logic:='0';
signal HPOS: integer:=0;
signal VPOS: integer:=0;
signal vidOn:std_logic:='0';
constant HorHD : integer:= 639;
constant HorFP: integer:= 16;
constant HorSP: integer:= 96;
constant HorBP: integer:= 48;
constant VerHD: integer:= 479;
constant VerFP: integer:= 10;
constant VerSP: integer:= 2;
constant VerBP: integer:= 33;
signal a:integer:=0;
signal c: integer:=0;
signal d:integer:=0;

signal state:integer:=1;
-- RAM
signal ram_data_in: std_logic_vector(7 downto 0):=(others=>'0');
signal ram_data_out: std_logic_vector(7 downto 0):=(others=>'0');
signal ram_address: std_logic_vector(11 downto 0):=(others=>'0');
--Filter ROM
signal filter_data:std_logic_vector(7 downto 0);
signal filter_address: std_logic_vector(3 downto 0):= "0000";
signal f: register_array(8 downto 0);

--ROM Image
signal rom_data: std_logic_vector(7 downto 0); 
signal rom_address: std_logic_vector(11 downto 0):=(others=>'0');
signal write_enable: std_logic := '1';
signal clk25: std_logic:='0';
--Compute Module
signal cm_enable:std_logic:='0';
signal pixels:register_array(8 downto 0);
signal result: std_logic_vector(20 downto 0);
--Shift Register
--signal clock:std_logic:='0';
--signal reset:std_logic:='0';

signal shift_reg: INTEGER_ARRAY(0 to 134) := (others => 0);
signal shift_pixel:register_array(8 downto 0):=(others=>(others=>'0'));
type ram_r is array(4095 downto 0) of std_logic_vector(20 downto 0);
signal ram_register:ram_r:=(others=>(others=>'0'));
type ram_r1 is array(4095 downto 0) of std_logic_vector(7 downto 0);
signal ram_register1:ram_r1:=(others=>(others=>'0'));
signal grad_done:std_logic:='0';
signal maxi:integer:=-1048576;
signal mini:integer:=1048576;
signal norm_done:std_logic:='0';
signal filter_done:integer:=0;
signal ram_val:integer:=0;
signal l:integer:=0;

signal state_x:integer:=0;
--End of Signal Declaration

--Component Declarations
component dist_mem_gen_3 port(
    clk: in std_logic;
    a: in std_logic_vector(11 downto 0);
    spo:out std_logic_vector(7 downto 0)
);
end component;

component filterROM port(
    clk: in std_logic;
    a: in std_logic_vector(3 downto 0);
    spo: out std_logic_vector(7 downto 0)
);
end component;

component dist_mem_gen_1 port(
            clk: in std_logic;
            d: in std_logic_vector(7 downto 0);
            a: in std_logic_vector(11 downto 0);
            spo: out std_logic_vector(7 downto 0);
            we: in std_logic
);
end component;

component ComputeModule Port (
            clk: in std_logic;
            enable: in std_logic; 
            filter: in register_array(8 downto 0);
            pixels: in register_array(8 downto 0);
            result:out std_logic_vector(20 downto 0)
  );
end component;

begin

--Including ROM/RAM in the Module
uut1: dist_mem_gen_3 port map(
    clk=>clock,
    a => rom_address,
    spo => rom_data
);

uut2: filterROM PORT MAP(
    a => filter_address,
    clk => clock,
    spo => filter_data
);
uut3: dist_mem_gen_1 PORT MAP(
    clk => clk25,
    a => ram_address,
    d => ram_data_in,
    spo => ram_data_out,
    we => write_enable
);
uut4: ComputeModule PORT MAP(
    clk=> clock,
    enable =>cm_enable,
    filter =>f,
    pixels =>shift_pixel,
    result =>result
);

--clock_pr:process    
--begin
--    clock<=not clock;
--    wait for 10ns;
--end process;

clock_div: process(clock)
variable counter: integer:=0;
 begin
    if(rising_edge(clock)) then
        if(counter < 1) then
            counter := counter+1;
        elsif(counter=1) then
            counter := 0;
            clk25<=not clk25;
         end if;
    end if;
 end process;
 

filter_process:process 
begin
        cm_enable <= '1';
        f <= (others => (others => '0')); -- Initialize to zero
        pixels <= (others => (others => '0')); -- Initialize to zero
        for i in 0 to 8 loop
            filter_address <= std_logic_vector(to_unsigned(i,4));
            wait for 20ns;
            f(i)<= filter_data; 
        end loop;
        wait;
end process;


grad_process:process(clock)
variable state:integer:=1;
variable i:integer:=1;
variable j:integer:=1;
variable x:integer:=0;
--variable y:integer:=0;
variable v:integer:=0;
begin
    if(rising_edge(clock)) then
        if(state=1) then
            if(j<65) and(j>0) then
                if(i<65) and (i>0) then    
                    if(x=0) then
                        rom_address<=std_logic_vector(to_unsigned((i-1)+64*(j-1)+1,12));
                        x:=1;
                    elsif(x=1) then
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= to_integer(unsigned(rom_data));
                        
                        x:=2;
                    elsif(x=2) then
                        shift_pixel(0)<= std_logic_vector(to_unsigned(shift_reg(0),8));
                        shift_pixel(1)<= std_logic_vector(to_unsigned(shift_reg(1),8));
                        shift_pixel(2)<= std_logic_vector(to_unsigned(shift_reg(2),8));
                        shift_pixel(3)<= std_logic_vector(to_unsigned(shift_reg(66),8));
                        shift_pixel(4)<= std_logic_vector(to_unsigned(shift_reg(67),8));
                        shift_pixel(5)<= std_logic_vector(to_unsigned(shift_reg(68),8));
                        shift_pixel(6)<= std_logic_vector(to_unsigned(shift_reg(132),8));
                        shift_pixel(7)<= std_logic_vector(to_unsigned(shift_reg(133),8));
                        shift_pixel(8)<= std_logic_vector(to_unsigned(shift_reg(134),8));
                        x:=3;
                    elsif(x=3) then
                        x:=4;
                    elsif(x=4) then
                        x:=5;    
                    else
                        if(i>1) and(j>1) then
                            ram_register(i-2+64*(j-2))<=result;
                            if(maxi < to_integer(signed(result))) then
                              maxi<= to_integer(signed(result)) ;
                            end if;
                            if(mini > to_integer(signed(result))) then
                              mini <= to_integer(signed(result));
                            end if;
                        end if;
                        x:=0;
                        i:=i+1;    
                    end if;
                elsif(i=0) then
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= 0;
                        
                        i:=i+1;
                elsif(i=65) then
                     if(x=0) then 
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= 0;
                        x:=1;
                     elsif(x=1) then
                        shift_pixel(0)<= std_logic_vector(to_unsigned(shift_reg(0),8));
                        shift_pixel(1)<= std_logic_vector(to_unsigned(shift_reg(1),8));
                        shift_pixel(2)<= std_logic_vector(to_unsigned(shift_reg(2),8));
                        shift_pixel(3)<= std_logic_vector(to_unsigned(shift_reg(66),8));
                        shift_pixel(4)<= std_logic_vector(to_unsigned(shift_reg(67),8));
                        shift_pixel(5)<= std_logic_vector(to_unsigned(shift_reg(68),8));
                        shift_pixel(6)<= std_logic_vector(to_unsigned(shift_reg(132),8));
                        shift_pixel(7)<= std_logic_vector(to_unsigned(shift_reg(133),8));
                        shift_pixel(8)<= std_logic_vector(to_unsigned(shift_reg(134),8));
                        x:=2;
                     elsif(x=2) then
                        x:=3;
                     elsif(x=3) then
                        x:=4;
                     else   
                        if(i>1) and(j>1) then
                            ram_register(i-2+64*(j-2))<=result;
                            if(maxi < to_integer(signed(result))) then
                              maxi<= to_integer(signed(result)) ;
                            end if;
                            if(mini > to_integer(signed(result))) then
                              mini <= to_integer(signed(result));
                            end if;
                        end if;
                        x:=0;
                        i:=0;
                        j:=j+1;
                     end if;
                end if;
            elsif(j=65) then
                if(i<65) and (i>0) then    
                    if(x=0) then
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= 0;
                        
                        x:=2;
                    elsif(x=2) then
                        shift_pixel(0)<= std_logic_vector(to_unsigned(shift_reg(0),8));
                        shift_pixel(1)<= std_logic_vector(to_unsigned(shift_reg(1),8));
                        shift_pixel(2)<= std_logic_vector(to_unsigned(shift_reg(2),8));
                        shift_pixel(3)<= std_logic_vector(to_unsigned(shift_reg(66),8));
                        shift_pixel(4)<= std_logic_vector(to_unsigned(shift_reg(67),8));
                        shift_pixel(5)<= std_logic_vector(to_unsigned(shift_reg(68),8));
                        shift_pixel(6)<= std_logic_vector(to_unsigned(shift_reg(132),8));
                        shift_pixel(7)<= std_logic_vector(to_unsigned(shift_reg(133),8));
                        shift_pixel(8)<= std_logic_vector(to_unsigned(shift_reg(134),8));
                        x:=3;
                    elsif(x=3) then
                        x:=4;
                    elsif(x=4) then
                        x:=5;    
                    else
                        if(i>1) and(j>1) then
                            ram_register(i-2+64*(j-2))<=result;
                            if(maxi < to_integer(signed(result))) then
                              maxi<= to_integer(signed(result)) ;
                            end if;
                            if(mini > to_integer(signed(result))) then
                              mini <= to_integer(signed(result));
                            end if;
                        end if;
                        x:=0;
                        i:=i+1;    
                    end if;
                elsif(i=0) then
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= 0;
                        
                        i:=i+1;
                elsif(i=65) then
                     if(x=0) then 
                        shift_reg(0 to 133) <= shift_reg(1 to 134);
                        shift_reg(134) <= 0;

                        x:=1;
                     elsif(x=1) then
                        shift_pixel(0)<= std_logic_vector(to_unsigned(shift_reg(0),8));
                        shift_pixel(1)<= std_logic_vector(to_unsigned(shift_reg(1),8));
                        shift_pixel(2)<= std_logic_vector(to_unsigned(shift_reg(2),8));
                        shift_pixel(3)<= std_logic_vector(to_unsigned(shift_reg(66),8));
                        shift_pixel(4)<= std_logic_vector(to_unsigned(shift_reg(67),8));
                        shift_pixel(5)<= std_logic_vector(to_unsigned(shift_reg(68),8));
                        shift_pixel(6)<= std_logic_vector(to_unsigned(shift_reg(132),8));
                        shift_pixel(7)<= std_logic_vector(to_unsigned(shift_reg(133),8));
                        shift_pixel(8)<= std_logic_vector(to_unsigned(shift_reg(134),8));
                        x:=2;
                     elsif(x=2) then
                        x:=3;
                     elsif(x=3) then
                        x:=4;    
                     else   
                        if(i>1) and(j>1) then
                            ram_register(i-2+64*(j-2))<=result;
                            if(maxi < to_integer(signed(result))) then
                              maxi<= to_integer(signed(result)) ;
                            end if;
                            if(mini > to_integer(signed(result))) then
                              mini <= to_integer(signed(result));
                            end if;
                        end if;
                        x:=0;
                        i:=0;
                        j:=j+1;
                        state:=2;
                     end if;
                end if;    
            end if;
        elsif(state=2) then 
                state:=3;
        elsif(state=3) then
--            ram_enable<='0';
            grad_done<='1';
            state:=4;
        end if;
        
    end if;
    
end process;

norm_process:process(clk25)
variable k: integer:=0;
variable v:integer:=0;
--variable a:integer:=0;
--variable c:integer:=0;
--variable d:integer:=0;
begin
    if(rising_edge(clk25) and grad_done='1') then
        if(k<4096) then
            if(a=0) then
                c<=to_integer(signed(ram_register(k)));
                a<=1;
                write_enable<='0';
            elsif(a=1) then
                ram_address <=std_logic_vector(to_unsigned(k,12));
                d<=maxi-mini;
                c<=c-mini;
                a<=2;
            elsif(a=2) then
                c<=c*255;
                a<=3;
--                write_enable<='1';
            elsif(a=3) then
                c<=c/d;
                a<=4;
            else
                ram_data_in<= std_logic_vector(TO_UNSIGNED(c,8));
                write_enable<='1';
                k:=k+1;
                a<=0;
            end if;
        elsif(k=4096) then
            write_enable<='0';
            norm_done<='1';
            k:=k+1;
        else
            if(norm_done='1') and(write_enable<='0') then
                v:=hPos+64*vPos+1;
                ram_address<=std_logic_vector(to_unsigned(v,12));
   
            end if;
        end if;
    end if;
end process;

Hpos_countkrnewawla:process(clk25,reset)
     begin
        if(norm_done='1') then
            if(write_enable='0') then
                if(reset='1')then
                    hpos<=0;
                elsif(clk25'event and clk25='1') then
                    
                    if(hpos=(HorHD+HorFP+HorSP+HorBP)) then
                        hpos<=0;
                    else
                        hpos<=hpos+1;
                    end if;
                end if;
            else
                hpos<=0;
            end if;
        end if;
end process;

Vpos_countkrnewawla:process(clk25,reset,hpos)
     begin
         if(norm_done='1') then
            if(write_enable='0') then
                if(reset ='1')then
                    vpos<=0;
                elsif(clk25'event and clk25='1') then
                    if(hpos = HorHD+ HorFP+HorSP+HorBP) then
                        if( vpos = (VerHD+VerFP+VerSP+VerBP)) then
                            vpos<=0;
                        else
                            vpos<=vpos+1;
                        end if;
                    end if;
                end if;
            else
                vpos<=0;
            end if;
        end if;
end process;

Hor_Sync:process(clk25,reset,hpos)
     begin
         if(norm_done='1') then
            if(write_enable ='0') then
                if(reset='1')then
                    HSYNC<='0';
                elsif(clk25'event and clk25='1')then
                    if((hpos<=(HorHD+HorFP))OR(hpos>HorHD+HorFP+HorSP)) then
                        HSYNC<='1';
                    else
                        HSYNC<='0';
                    end if;
                end if;
            else
                HSYNC<='0';
            end if;
        end if;
 end process;

 Ver_Sync:process(clk25,reset,vpos)
     begin
         if(norm_done='1') then
            if(write_enable ='0') then
                if(reset='1')then
                    VSYNC<='0';
                elsif(clk25'event and clk25='1')then
                    if((vpos<=(VerHD+VerFP)) OR (vpos>VerHD+VerFP+VerSP))  then
                        VSYNC<='1';
                    else
                        VSYNC<='0';
                    end if;
                end if;
            else
                VSYNC <='0';
            end if;
        end if;
 end process;

      
VIDEO_ON:process(clk25,reset,hpos,vpos)
     begin
            if(norm_done='1') then
                if(write_enable='0') then
                    if(reset='1')then
                        vidOn<='0';
                    elsif(clk25'event and clk25='1')then
                        if(hpos<=HorHD and vpos<=VerHD)then
                            vidOn<='1';
                        else
                            vidOn<='0';
                        end if;
                    end if;
                end if;
            end if;
end process;

Display:process(vidOn,vpos,hpos,clk25,reset,ram_address)
variable l: integer:=0;
    begin
        if(write_enable= '0' and norm_done='1') then
            if(reset = '1') then
                vgaRed <= "0000";
                vgaBlue <= "0000";
                vgaGreen <= "0000";
            elsif(rising_edge(clk25)) then
                if(vidOn ='1') then
                    if(vpos>=0 and vpos < 64 ) and (hpos >=0 and hpos <64 ) then
                        vgaRed(3) <= ram_data_out(7);
                        vgaRed(2) <= ram_data_out(6);
                        vgaRed(1) <= ram_data_out(5);
                        vgaRed(0) <= ram_data_out(4);
                        vgaBlue(3) <= ram_data_out(7);
                        vgaBlue(2) <= ram_data_out(6);
                        vgaBlue(1) <= ram_data_out(5);
                        vgaBlue(0) <= ram_data_out(4);
                        vgaGreen(3) <= ram_data_out(7);
                        vgaGreen(2) <= ram_data_out(6);
                        vgaGreen(1) <= ram_data_out(5);
                        vgaGreen(0) <= ram_data_out(4);
                    else
                        vgaRed <="0000";
                        vgaBlue <="0000";
                        vgaGreen <= "0000";
                    end if;
                end if; 
            end if;
        else
                vgaRed <= "0000";
                vgaBlue <= "0000";
                vgaGreen <= "0000";
        end if;
end process;

end Behavioral;


-- uart_rx.vhd: UART controller - receiving (RX) side
-- Author(s): Tadeáš (xnovot00)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-- Entity declaration (DO NOT ALTER THIS PART!)
entity UART_RX is
    port(
        CLK      : in std_logic;
        RST      : in std_logic;
        DIN      : in std_logic;
        DOUT     : out std_logic_vector(7 downto 0);
        DOUT_VLD : out std_logic
    );
end entity;

-- Architecture implementation (INSERT YOUR IMPLEMENTATION HERE)
architecture behavioral of UART_RX is
    signal mid_cnt      : std_logic_vector(4 downto 0);     -- hodinové počítadlo
    signal bit_cnt      : std_logic_vector(3 downto 0);     -- počítadlo CLK % 16
    signal data_vld     : std_logic;                        -- validačný signál
    signal mid_cnt_en   : std_logic;                        -- povolovací signál pre CNT
    signal data_rcv_en  : std_logic;                        -- povolovací signál pre CNT2 a DMX

begin
    -- Instance of RX FSM
    fsm: entity work.UART_RX_FSM
    port map (
        CLK         =>  CLK,
        RST         =>  RST,
        DIN         =>  DIN,
        MID_CNT     =>  mid_cnt,
        BIT_CNT     =>  bit_cnt,
        DATA_VLD    =>  data_vld,
        CNT_EN      =>  mid_cnt_en,
        RCV_EN      =>  data_rcv_en
    );


    DOUT_VLD <= data_vld;

    process(CLK)
    begin
        if rising_edge (CLK) then
            if mid_cnt_en = '1' then
                mid_cnt <= mid_cnt + 1;
            else
                mid_cnt <= "00010";
                bit_cnt <= "0000";
            end if;
            if data_rcv_en = '1' then
                if mid_cnt(4) = '1' then
                    mid_cnt <= "00001";
                    case bit_cnt is
                        when "0000" =>
                            DOUT(0) <= DIN;
                        when "0001" =>
                            DOUT(1) <= DIN;
                        when "0010" =>
                            DOUT(2) <= DIN;
                        when "0011" =>
                            DOUT(3) <= DIN;
                        when "0100" =>
                            DOUT(4) <= DIN;
                        when "0101" =>
                            DOUT(5) <= DIN;
                        when "0110" =>
                            DOUT(6) <= DIN;
                        when "0111" =>
                            DOUT(7) <= DIN;
                        when others =>
                            null;
                    end case;
                    bit_cnt <= bit_cnt + 1;
                end if;
            end if;
        end if;
        
    end process;

end architecture;

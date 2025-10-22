library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fpu_double_top is
  port (
    clk, rst       : in  std_logic;
    start          : in  std_logic;  -- pulse to begin input sequence
    data_in_a      : in  std_logic_vector(15 downto 0);
    data_in_b      : in  std_logic_vector(15 downto 0);
    data_in_valid  : in  std_logic;
    rmode          : in  std_logic_vector(1 downto 0);
    fpu_op         : in  std_logic_vector(2 downto 0);
    data_out       : out std_logic_vector(15 downto 0);
    data_out_valid : out std_logic;
    done           : out std_logic
  );
end entity;

architecture rtl of fpu_double_top is

  type state_t is (
    IDLE,
    LOAD_OP,
    START_FPU,
    WAIT_RESULT,
    OUTPUT_RESULT
  );
  signal state, next_state : state_t;

  signal opa_buf, opb_buf : std_logic_vector(63 downto 0);
  signal out_buf          : std_logic_vector(63 downto 0);

  signal word_cnt : integer range 0 to 3;

  -- FPU signals
  signal fpu_out    : std_logic_vector(63 downto 0);
  signal fpu_ready  : std_logic;

begin

  -------------------------------------------------------------------
  -- Instance of original FPU
  -------------------------------------------------------------------
  i_fpu: entity work.fpu_double
    port map (
      clk       => clk,
      rst       => rst,
      enable    => (state = START_FPU),
      rmode     => rmode,
      fpu_op    => fpu_op,
      opa       => opa_buf,
      opb       => opb_buf,
      out_fp    => fpu_out,
      ready     => fpu_ready,
      underflow => open,
      overflow  => open,
      inexact   => open,
      exception => open,
      invalid   => open
    );

  -------------------------------------------------------------------
  -- State register
  -------------------------------------------------------------------
  process(clk, rst)
  begin
    if rst = '1' then
      state <= IDLE;
      word_cnt <= 0;
      opa_buf <= (others=>'0');
      opb_buf <= (others=>'0');
      out_buf <= (others=>'0');
    elsif rising_edge(clk) then
      state <= next_state;

      if state = LOAD_OP and data_in_valid='1' then
        opa_buf(16*word_cnt+15 downto 16*word_cnt) <= data_in_a;
        word_cnt <= word_cnt + 1;
      elsif state = LOAD_OP and data_in_valid='1' then
        opb_buf(16*word_cnt+15 downto 16*word_cnt) <= data_in_b;
        word_cnt <= word_cnt + 1;
      elsif state = OUTPUT_RESULT and data_out_valid='1' then
        word_cnt <= word_cnt + 1;
      elsif state /= state'last then
        word_cnt <= 0;
      end if;

      if state = WAIT_RESULT and fpu_ready='1' then
        out_buf <= fpu_out;
      end if;
    end if;
  end process;

  -------------------------------------------------------------------
  -- Next state logic
  -------------------------------------------------------------------
  process(state, start, data_in_valid, word_cnt, fpu_ready)
  begin
    next_state <= state;
    case state is
      when IDLE =>
        if start='1' then
          next_state <= LOAD_OP;
        end if;

      when LOAD_OP =>
        if data_in_valid='1' and word_cnt=3 then
          next_state <= START_FPU;
        end if;

      when START_FPU =>
        next_state <= WAIT_RESULT;

      when WAIT_RESULT =>
        if fpu_ready='1' then
          next_state <= OUTPUT_RESULT;
        end if;

      when OUTPUT_RESULT =>
        if word_cnt=3 then
          next_state <= IDLE;
        end if;

      when others =>
        next_state <= IDLE;
    end case;
  end process;

  -------------------------------------------------------------------
  -- Output logic
  -------------------------------------------------------------------
  data_out_valid <= '1' when state=OUTPUT_RESULT else '0';
  data_out       <= out_buf(16*word_cnt+15 downto 16*word_cnt);
  done           <= '1' when (state=OUTPUT_RESULT and word_cnt=3 and data_out_valid='1') else '0';

end rtl;
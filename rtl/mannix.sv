module mannix #(
	parameter ADDR_WIDTH=19,
  parameter X_ROWS_NUM=5,
  parameter X_COLS_NUM=5,
                     
  parameter X_LOG2_ROWS_NUM =$clog2(X_ROWS_NUM),
  parameter X_LOG2_COLS_NUM =$clog2(X_COLS_NUM), 
  

  parameter Y_ROWS_NUM=2,
  parameter Y_COLS_NUM=2,
                     
  parameter Y_LOG2_ROWS_NUM =$clog2(Y_ROWS_NUM),
  parameter Y_LOG2_COLS_NUM =$clog2(Y_COLS_NUM),

  parameter DATA_ROWS_NUM=4,  
  parameter DATA_COLS_NUM=4,  
  parameter DATA_LOG2_ROWS_NUM = $clog2(DATA_ROWS_NUM),
  parameter DATA_LOG2_COLS_NUM = $clog2(DATA_COLS_NUM),

  parameter RES_ROWS_NUM=2,
  parameter RES_COLS_NUM=2,
  parameter OUT_LOG2_ROWS_NUM=$clog2(RES_ROWS_NUM),
  parameter OUT_LOG2_COLS_NUM=$clog2(RES_COLS_NUM)

		)
	(
	input clk,
	input rst_n,
	//port for memory
	input [31:0] read_addr_ddr,
	input [31:0] write_addr_ddr,
	input [4:0] client_priority,
	//port for fcc
	input [31:0] FC_ADDRX, 
  	input [31:0] FC_ADDRY,
  	input [31:0] FC_ADDRB,
  	input [31:0] FC_XM,
  	input [31:0] FC_YM,
  	input [31:0] FC_YN,
  	input [31:0] CNN_BN,
  	input FC_GO,
  	output [31:0] FC_ADDRZ,
  	output FC_DONE,
  	//port for active
  	input [31:0] ACTIV_ADDRX, 
  	input [31:0] ACTIV_XM,
  	input [31:0] ACTIV_YM,
  	input ACTIV_GO, 
  	output [31:0] ACTIV_ADDRZ,
  	output ACTIV_DONE,
  	//port for pool
    input [ADDR_WIDTH-1:0]            sw_pool_rd_addr,	//POOL Data matrix FIRST address
    input [ADDR_WIDTH-1:0]            sw_pool_wr_addr,	//POOL return address
    input [DATA_LOG2_ROWS_NUM-1:0]    sw_pool_rd_m,  	//POOL data matrix num of rows
    input [DATA_LOG2_COLS_NUM-1:0]    sw_pool_rd_n,	//POOL data matrix num of columns
    input [OUT_LOG2_ROWS_NUM-1:0]     sw_pool_m,	//POOL size - rows
    input [OUT_LOG2_COLS_NUM-1:0]     sw_pool_n,	//POOL size - columns 
    output                            pool_sw_busy_ind,	//An output to the software - 1 – POOL unit is busy - 0 -POOL is available (Default)
  	//port for fcc
    input [ADDR_WIDTH-1:0]            sw_cnn_addr_x,	// CNN Data window FIRST address
    input [ADDR_WIDTH-1:0]            sw_cnn_addr_y,	// CNN  weights window FIRST address
    input [ADDR_WIDTH-1:0]            sw_cnn_addr_z,	// CNN return address
    input [X_LOG2_ROWS_NUM-1:0]       sw_cnn_x_m,  	// CNN data matrix num of rows
    input [X_LOG2_COLS_NUM-1:0]       sw_cnn_x_n,	        // CNN data matrix num of columns
    input [Y_LOG2_ROWS_NUM-1:0]       sw_cnn_y_m,	        // CNN weight matrix num of rows
    input [Y_LOG2_COLS_NUM-1:0]       sw_cnn_y_n,	        // CNN weight matrix num of columns 
    output reg                        cnn_sw_busy_ind	// An output to the software - 1 – CNN unit is busy CNN is available (Default)
  	);


  	mem_intf_read FC_READ();
  	mem_intf_write FC_WRITE();
  	mem_intf_read ACTIV_READ();
  	mem_intf_write ACTIV_WRITE();
  	mem_intf_write mem_intf_write_pool();
  	mem_intf_read mem_intf_read_mx_pool();
  	mem_intf_write mem_intf_write_cnn();
  	mem_intf_read mem_intf_read_pic_cnn();
  	mem_intf_read mem_intf_read_wgt_cnn();
	mem_intf_read read_ddr_req();
	mem_intf_write write_ddr_req ();
  	fcc i_fcc (
  	.clk(clk),
  	.FC_ADDRX(FC_ADDRX),
  	.FC_ADDRY(FC_ADDRY),
  	.FC_ADDRB(FC_ADDRB),
  	.FC_ADDRZ(FC_ADDRZ),
  	.FC_XM(FC_XM),
  	.FC_YM(FC_YM),
  	.FC_YN(FC_YN),
  	.CNN_BN(CNN_BN),
  	.GO(FC_GO),
  	.DONE(FC_DONE),
  	.READ(FC_READ),
  	.WRITE(FC_WRITE)
  	);

  	active i_active (
  	.READ(ACTIV_READ),
  	.WRITE(ACTIV_WRITE),
  	.clk(clk),
  	.ACTIV_ADDRX(ACTIV_ADDRX),
  	.ACTIV_XM(ACTIV_XM),
  	.ACTIV_YM(ACTIV_YM),
  	.GO(ACTIV_GO),
  	.FC_ADDRZ(FC_ADDRZ),
  	.DONE(ACTIV_DONE)
  	);

  	pool i_pool (
  		.clk(clk),
       	.rst_n(rst_n),
        .mem_intf_write(mem_intf_write_pool),
        .mem_intf_read_mx(mem_intf_read_mx_pool),    
        .pool_sw_busy_ind(pool_sw_busy_ind),
        .sw_pool_rd_addr(sw_pool_rd_addr),
        .sw_pool_wr_addr(sw_pool_wr_addr),
        .sw_pool_rd_m(sw_pool_rd_m),   
        .sw_pool_rd_n(sw_pool_rd_n),
        .sw_pool_m(sw_pool_m),   
        .sw_pool_n(sw_pool_n)
        );
	
	cnn i_cnn (
		.clk(clk),
       	.rst_n(rst_n),
		.mem_intf_write(mem_intf_write_cnn),
		.mem_intf_read_pic(mem_intf_read_pic_cnn),
        .mem_intf_read_wgt(mem_intf_read_wgt_cnn),        
        .cnn_sw_busy_ind(cnn_sw_busy_ind),
        .sw_cnn_addr_x(sw_cnn_addr_x),
        .sw_cnn_addr_y(sw_cnn_addr_y),
        .sw_cnn_addr_z(sw_cnn_addr_z),
        .sw_cnn_x_m(sw_cnn_x_m),  
        .sw_cnn_x_n(sw_cnn_x_n),
        .sw_cnn_y_m(sw_cnn_y_m),
        .sw_cnn_y_n(sw_cnn_y_n)
	);

	mannix_mem_farm i_mannix_mem_farm (
	.fcc_r(FC_READ),
	.active_r(ACTIV_READ),
	.cnn_pic_r(mem_intf_read_pic_cnn),
	.cnn_wgt_r(mem_intf_read_wgt_cnn),
	.pool_r(mem_intf_read_mx_pool),
	.fcc_w(FC_WRITE),
	.active_w(ACTIV_WRITE),
	.pool_w(mem_intf_write_pool),
	.cnn_w(mem_intf_write_cnn),
	.read_addr_ddr(read_addr_ddr),
	.write_addr_ddr(write_addr_ddr),
	.client_priority(client_priority),
	.read_ddr_req(read_ddr_req),
	.write_ddr_req(write_ddr_req)
	);
	
endmodule

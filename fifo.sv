module fifo #(
    parameter DATA_WIDTH = 8, // Latime date
    parameter FIFO_DEPTH = 4  // Adancime coada
) (
    input clk_i, rst_i,       // Ceas si Reset
    
    input wr_i,               // Cerere scriere
    input [DATA_WIDTH-1:0] data_i, // Date intrare
    output reg full_o,        // Semnal PLIN
    
    input rd_i,               // Cerere citire
    output reg [DATA_WIDTH-1:0] data_o, // Date iesire
    output reg empty_o        // Semnal GOL
);

    // Calcul marime pointeri si contor
    localparam ADDR_WIDTH = $clog2(FIFO_DEPTH); 
    localparam COUNT_WIDTH = $clog2(FIFO_DEPTH) + 1;

    reg [DATA_WIDTH-1:0]    mem [FIFO_DEPTH-1:0]; // Memoria interna
    reg [ADDR_WIDTH-1:0]    wr_ptr; // Pointer scriere
    reg [ADDR_WIDTH-1:0]    rd_ptr; // Pointer citire
    reg [COUNT_WIDTH-1:0]   count;  // Numar elemente stocate

    // Protectie: scrie doar daca nu e plin / citeste doar daca nu e gol
    wire wr_en = wr_i && !full_o; 
    wire rd_en = rd_i && !empty_o;

    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            count   <= 0;
            full_o  <= 0;
            empty_o <= 1; // La reset e gol
        end else begin
            
            // Scriere: creste contorul
            if (wr_en && !rd_en) begin 
                count <= count + 1;
                if (count + 1 == FIFO_DEPTH) full_o <= 1;
                empty_o <= 0;
            end
            
            // Citire: scade contorul
            else if (!wr_en && rd_en) begin 
                count <= count - 1;
                if (count - 1 == 0) empty_o <= 1;
                full_o <= 0;
            end
        end
    end

    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            wr_ptr <= 0;
        end else begin
            if (wr_en) begin
                mem[wr_ptr] <= data_i; // Salveaza datele
                wr_ptr      <= (wr_ptr + 1) % FIFO_DEPTH; 
            end
        end
    end
    
    always @(posedge clk_i or negedge rst_i) begin
        if (!rst_i) begin
            rd_ptr <= 0;
            data_o <= 0;
        end else begin
            if (rd_en) begin
                data_o <= mem[rd_ptr]; // Scoate datele
                rd_ptr <= (rd_ptr + 1) % FIFO_DEPTH; 
            end
        end
    end

endmodule
module switch #(
    parameter DATA_WIDTH = 8, // Latime totala date (Adresa + Payload)
    parameter FIFO_DEPTH = 4  // Adancime buffer intern
) (
    input  wire clk_i, // Ceas sistem
    input  wire rst_i, // Reset sistem

    input valid_i,                  // Semnal date valide de la sursa
    input  wire [DATA_WIDTH-1:0] data_in, // Date intrare (8 biti)
    output reg ready_o,             // Semnal "Gata de primire" (catre sursa)

    output reg [3:0] valid_out,     // Semnal valid pentru fiecare iesire
    output reg [DATA_WIDTH-3:0] device0, // Date pt Device 0 (6 biti)
    output reg [DATA_WIDTH-3:0] device1, // Date pt Device 1 (6 biti)
    output reg [DATA_WIDTH-3:0] device2, // Date pt Device 2 (6 biti)
    output reg [DATA_WIDTH-3:0] device3, // Date pt Device 3 (6 biti)
    input [3:0] ready_i,            // Semnal "Gata" de la fiecare device

    // Semnale Stare FIFO (debug/monitorizare)
    output wire status_full,
    output wire status_empty
);

    // Semnale interne de control pentru FIFO
    wire rd_sw; // Comanda citire din FIFO
    wire wr_sw; // Comanda scriere in FIFO

    // Fire pentru datele extrase din FIFO
    wire [DATA_WIDTH-1:0] fifo_data_out; // Date brute din FIFO (8 biti)
    wire [1:0]            sw_addr;       // Adresa extrasa (2 biti)
    wire [DATA_WIDTH-3:0] sw_data;       // Payload extras (6 biti)

    // Scriem in FIFO doar daca sursa are date valide SI FIFO nu e plin
    assign wr_sw = valid_i & ready_o;

    // Citim din FIFO doar daca destinatarul curent confirma ca e gata (ready_i)
    // Se verifica bitul corespunzator canalului activ
    assign rd_sw = (valid_out[0] & ready_i[0]) ||
                   (valid_out[1] & ready_i[1]) ||
                   (valid_out[2] & ready_i[2]) ||
                   (valid_out[3] & ready_i[3]);

    // Primii 2 biti sunt adresa 
    assign sw_addr = fifo_data_out[DATA_WIDTH-1:DATA_WIDTH-2];
    // Restul de 6 biti sunt datele utile 
    assign sw_data = fifo_data_out[DATA_WIDTH-3 : 0];

    // --- Instantiere FIFO ---
    fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .FIFO_DEPTH(FIFO_DEPTH)
    ) u_fifo (
        .clk_i   (clk_i),
        .rst_i   (rst_i),
        .wr_i    (wr_sw),       // Conectare logica scriere
        .data_i  (data_in),
        .full_o  (status_full),
        .rd_i    (rd_sw),       // Conectare logica citire
        .data_o  (fifo_data_out),
        .empty_o (status_empty)
    );

    always @(*) begin
        // Resetare implicita valori
        device0   = 0;
        device1   = 0;
        device2   = 0;
        device3   = 0;
        valid_out = 4'b0000;

        // Procesam doar daca FIFO nu e gol si sistemul e activ
        if (!status_empty && valid_i && ready_o) begin
            case (sw_addr) // Selectie in functie de adresa extrasa
                2'b00: begin
                    device0      = sw_data; // Trimite date la Dev 0
                    valid_out[0] = 1'b1;    // Valideaza iesirea 0
                end
                2'b01: begin
                    device1      = sw_data;
                    valid_out[1] = 1'b1;
                end
                2'b10: begin
                    device2      = sw_data;
                    valid_out[2] = 1'b1;
                end
                2'b11: begin
                    device3      = sw_data;
                    valid_out[3] = 1'b1;
                end
                default: begin
                    valid_out = 4'b0000;
                end
            endcase
        end
    end

    // Switch-ul e gata sa primeasca date doar daca FIFO nu e plin
    assign ready_o = !status_full;

endmodule
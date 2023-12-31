CREATE TABLE GestorAgricola (
    idGestorAgricola    INTEGER    CONSTRAINT pk_GestorAgricola_idGestorAgricola PRIMARY KEY
);

CREATE TABLE ExploracaoAgricola (
                                    idExploracaoAgricola    INTEGER    CONSTRAINT pk_ExploracaoAgricola_idExploracaoAgricola PRIMARY KEY,
                                    idGestorAgricola        INTEGER

);

CREATE TABLE Cliente (
                         codigoInterno       INTEGER     GENERATED BY DEFAULT AS IDENTITY CONSTRAINT pk_Cliente_codigoInterno PRIMARY KEY,
                         email               VARCHAR(50)	CONSTRAINT uk_Cliente_email UNIQUE,
                         CONSTRAINT ck_Cliente_email CHECK (email LIKE '%@%.%' ),

                         tipo                CHAR(1),
                         CONSTRAINT ck_Cliente_tipo CHECK (tipo IN ('E', 'P')), /*Empresa / Particular*/

                         plafond             NUMBER(8, 2),
                         CONSTRAINT ck_Cliente_plafond CHECK (plafond >= 0),

                         nivelNegocio        CHAR(1),
                         CONSTRAINT ck_Cliente_nivelNegocio CHECK (nivelNegocio IN ('A', 'B', 'C')),

                         nome                VARCHAR(50),
                         nif                 NUMBER(9),
                         CONSTRAINT ck_Cliente_nif CHECK (nif > 100000000),
                         idHub               VARCHAR(5)
);

CREATE TABLE ClienteExploracaoAgricola (
                                           idExploracaoAgricola    INTEGER,
                                           codigoInternoCliente    INTEGER,
                                           CONSTRAINT pk_ClienteExploracaoAgricola_idExploracaoAgricola_codigoInternoCliente PRIMARY KEY (idExploracaoAgricola, codigoInternoCliente)
);


CREATE TABLE CodigoPostal (
                              codigoPostal    CHAR(8),
                              localidade      VARCHAR(100),
                              CONSTRAINT ck_CodigoPostal_codigoPostal CHECK (codigoPostal LIKE '____-___' ),
                              CONSTRAINT pk_CodigoPostal_codigoPostal PRIMARY KEY (codigoPostal)
);


CREATE TABLE Morada (
                        codigoPostal            CHAR(8),
                        CONSTRAINT ck_Morada_codigoPostal CHECK (codigoPostal LIKE '____-___' ),

                        numeroPorta             INTEGER,
                        CONSTRAINT ck_Morada_numeroPorta CHECK (numeroPorta >= 0),
                        codigoInternoCliente    INTEGER,
                        tipoMorada              CHAR(1),
                        CONSTRAINT ck_Morada_tipoMorada CHECK (tipoMorada IN ('C', 'E')), /*Correspondencia / Entrega*/

                        CONSTRAINT pk_Morada_codigoPostal_numeroPorta PRIMARY KEY (codigoPostal, numeroPorta)
);


CREATE TABLE Encomenda (
                           numeroEncomenda         INTEGER     GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Encomenda_numeroEncomenda PRIMARY KEY,
                           codigoInternoCliente    INTEGER,
                           codigoPostalMorada      CHAR(8),
                           numeroPortaMorada       INTEGER,
                           dataEncomenda           DATE DEFAULT SYSDATE
                               CONSTRAINT nn_Encomenda_dataEncomenda NOT NULL,

                           estado                  CHAR(1),
                           CONSTRAINT ck_Encomenda_estado CHECK (estado IN ('R', 'E', 'P')), /* Registada / Encomendada / Paga */

                           dataEntrega             DATE,
                           CONSTRAINT ck_Encomenda_dataEntrega CHECK (dataEntrega >= dataEncomenda),

                           dataPagamento           DATE,
                           CONSTRAINT ck_Encomenda_dataPagamento CHECK (dataPagamento >= dataEncomenda),

                           valorTotal              NUMBER(8, 2),
                           CONSTRAINT ck_Encomenda_valorTotal CHECK (valorTotal >= 0),
                           idHub              VARCHAR(5)
);

CREATE TABLE Incidente (
                           idIncidente             INTEGER      GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Incidente_idIncidente PRIMARY KEY,
                           codigoInternoCliente    INTEGER,
                           numeroEncomenda         INTEGER,
                           valorDivida             NUMBER(8, 2),
                           CONSTRAINT ck_Incidente_valorDivida CHECK (valorDivida >= 0),
                           dataSanado              DATE,
                           CONSTRAINT ck_Incidente_dataSanado CHECK (dataSanado >= dataOcorrencia),
                           dataOcorrencia          DATE CONSTRAINT nn_Incidente_dataOcorrencia NOT NULL

);

CREATE TABLE EstacaoMeteorologica (
                                      idEstacaoMeteorologica      INTEGER     GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_EstacaoMeteorologica_idEstacaoMeteorologica PRIMARY KEY,
                                      idExploracaoAgricola        INTEGER
);

CREATE TABLE TipoSensor (
                            tipo        CHAR(2)     CONSTRAINT pk_TipoSensor_tipo PRIMARY KEY,
                            CONSTRAINT ck_TipoSensor_tipo CHECK (tipo IN ('HS', 'Pl', 'TS', 'VV', 'TA', 'HA', 'PA')), /* Humidade Solo / Pluviosidade / Temperatura solo / Velocidade Vento / temperatura Atmosférica / Humidade Ar / Pressão Atmosférica */

                            unidade     VARCHAR(5)  /*Exemplo: km/h*/
);

CREATE TABLE Sensor (
                        identificador               INTEGER     GENERATED BY DEFAULT AS IDENTITY CONSTRAINT pk_Sensor_identificador PRIMARY KEY,
                        idEstacaoMeteorologica      INTEGER,
                        tipoTipoSensor              CHAR(2)
);

CREATE TABLE SensorLeituras (
                         identificadorSensor              INTEGER,
                         tipoTipoSensor              CHAR(2),
                         valorLido                   INTEGER,
                         CONSTRAINT ck_Sensor_valorLido CHECK (valorLido >= 0 AND valorLido <= 100),
                         referencia                  INTEGER CONSTRAINT pk_SensorLeituras_referencia PRIMARY KEY,
                         instanteLeitura             VARCHAR(5)	    CONSTRAINT nn_Sensor_instanteLeitura NOT NULL

);

CREATE TABLE Setor (
                       designacao              VARCHAR(40),
                       idExploracaoAgricola    INTEGER,
                       areaTotal               NUMBER(8, 2),
                       CONSTRAINT ck_Setor_areaTotal CHECK (areaTotal >= 0),

                       CONSTRAINT pk_Setor_designacao_idExploracaoAgricola PRIMARY KEY (designacao, idExploracaoAgricola)
);


CREATE TABLE Auditoria (
                                  idAuditoria          INTEGER     GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Auditoria_idAuditoria PRIMARY KEY,
                                  idGestorAgricola            INTEGER,
                                  designacaoSetor             VARCHAR(40),
                                  idExploracaoAgricola        INTEGER,
                                  dataHora                    DATE	CONSTRAINT nn_Auditoria_dataHora NOT NULL,
                                  username                    VARCHAR(20) CONSTRAINT nn_Auditoria_username NOT NULL,
                                  operacaoEscrita             CHAR(6),
                                  CONSTRAINT ck_Auditoria_operacaoEscrita CHECK (operacaoEscrita IN ('INSERT', 'UPDATE', 'DELETE')) /* INSERT / UPDATE / DELETE */

);

CREATE TABLE OperacaoAgricola (
                                    idOperacaoAgricola          	INTEGER   GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_OperacaoAgricola_idOperacaoAgricola PRIMARY KEY,
                                    designacaoSetor             	VARCHAR(40),
                                    idExploracaoAgricola        	INTEGER,

                                    dataAgendada                	DATE		CONSTRAINT nn_OperacaoAgricola_dataAgendada NOT NULL,
                                    dataRealizacao              	DATE,
                                    CONSTRAINT ck_OperacaoAgricola_dataRealizacao CHECK (dataRealizacao >= dataAgendada),

                                    tipo                        	VARCHAR(40)	CONSTRAINT nn_OperacaoAgricola_tipo NOT NULL,
                                    estadoOperacao              	CHAR(1),
                                    CONSTRAINT ck_OperacaoAgricola_estadoOperacao CHECK (estadoOperacao IN ('A', 'C', 'R', 'P')) /* Atualizada / Cancelada / Realizada / Planeada */

);

CREATE TABLE FatorProducao (
                                nomeComercial           VARCHAR(30),
                                tipo                    CHAR(2),
                                CONSTRAINT ck_FatorProducao_tipo CHECK (tipo IN ('CM', 'FE', 'PF')), /* Corretivo Mineral / Fertilizante / Produto fitofármaco */

                                fornecedor                      VARCHAR(30)   CONSTRAINT nn_FatorProducaoConstituinte_fornecedor NOT NULL,

                                CONSTRAINT pk_FatorProducao_nomeComercial PRIMARY KEY (nomeComercial)
);

CREATE TABLE FatoresAplicados (
                                  idOperacaoAgricola		        INTEGER,
                                  nomeComercialFatorProducao	    VARCHAR(30),
                                  quantidadeAplicada		        NUMBER(5, 2),
                                  CONSTRAINT ck_FatoresAplicados_quantidadeAplicada CHECK (quantidadeAplicada >= 0),

                                  formaAplicacao                    VARCHAR(10),
                                  CONSTRAINT ck_OperacaoAgricola_formaAplicacao CHECK (formaAplicacao IN ('Foliar', 'Fertirrega', 'Solo')),

                                  CONSTRAINT pk_FatoresAplicados_idOperacaoAgricola_nomeComercialFatorProducao PRIMARY KEY (idOperacaoAgricola, nomeComercialFatorProducao)

);

CREATE TABLE Restricao (
                           idRestricao                     INTEGER         GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Restricao_idRestricao PRIMARY KEY,
                           nomeComercialFatorProducao      VARCHAR(30),
                           dataInicial                     DATE             CONSTRAINT nn_Restricao_dataInicial NOT NULL,
                           dataFinal                       DATE,
                           CONSTRAINT ck_Restricao_dataFinal CHECK (dataFinal >= dataInicial)
);

CREATE TABLE RestricaoSetor (
                               idRestricao          INTEGER,
                               designacaoSetor      VARCHAR(40),
                               idExploracaoAgricola INTEGER,

                               CONSTRAINT pk_RestricaoSetor_idRestricao_designacaoSetor_idExploracaoAgricola PRIMARY KEY (idRestricao, designacaoSetor, idExploracaoAgricola)
);


CREATE TABLE Constituinte (
                              nome                VARCHAR(30),
                              quantidade          NUMBER(5, 2),
                              CONSTRAINT ck_Constituinte_quantidade CHECK (quantidade >= 0),

                              unidade             CHAR(5),
                              categoria           CHAR(1),
                              CONSTRAINT ck_Constituinte_categoria CHECK (categoria IN ('E', 'S')), /* Elemento / Substância */

                              CONSTRAINT pk_Constituinte_nome PRIMARY KEY (nome)
);

CREATE TABLE FatorProducaoConstituinte (
                                          nomeComercialFatorProducao      VARCHAR(30),
                                          nomeConstituinte                VARCHAR(30),
                                          CONSTRAINT pk_FatorProducaoConstituinte_nomeComercialFatorProducao_nomeConstituinte PRIMARY KEY (nomeComercialFatorProducao, nomeConstituinte)
);

CREATE TABLE Cultura (
                         idCultura               INTEGER      GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Cultura_idCultura PRIMARY KEY,
                         designacaoSetor         VARCHAR(40),
                         idExploracaoAgricola    INTEGER,
                         areaCultura             NUMBER(8, 2),
                         CONSTRAINT ck_Cultura_areaCultura CHECK (areaCultura >= 0),
                         tipo                    CHAR(1),
                         CONSTRAINT ck_Cultura_tipo CHECK (tipo IN ('P', 'T')), /* Permanente / temporário */

                         cultivo                 VARCHAR(40)

);

CREATE TABLE Produto (
                         idProduto               INTEGER      GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Produto_idProduto PRIMARY KEY,
                         nome                    VARCHAR(40)
);

CREATE TABLE CulturaProduto (
                                idCultura               INTEGER,
                                idProduto               INTEGER,
                                CONSTRAINT pk_CulturaProduto_idCultura_idProduto PRIMARY KEY (idCultura, idProduto)
);

CREATE TABLE Safra (
                       idSafra             INTEGER     GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_Safra_idSafra PRIMARY KEY,
                       idCultura           INTEGER,
                       quantidadeProducao  INTEGER,
                       CONSTRAINT ck_Safra_quantidadeProducao CHECK (quantidadeProducao >= 0),

                       lucro               NUMBER(8, 2)

);

CREATE TABLE Caracteristica (
                                idCaracteristica    INTEGER     GENERATED ALWAYS AS IDENTITY,
                                idCultura           INTEGER,
                                nome                VARCHAR(20),

                                CONSTRAINT pk_Caracteristica_idCaracteristica_idCultura PRIMARY KEY (idCaracteristica, idCultura)
);

CREATE TABLE Parametro (
                           idParametro         INTEGER      GENERATED ALWAYS AS IDENTITY,
                           idCaracteristica    INTEGER,
                           idCultura           INTEGER,
                           nome                VARCHAR(20),

                           CONSTRAINT pk_Parametro_idParamentro_idCaracteristica_idCultura PRIMARY KEY (idParametro, idCaracteristica, idCultura)
);


CREATE TABLE Input_Sensor(
                           input_string        VARCHAR(25)
);

CREATE TABLE Input_Hub(
                           input_string       VARCHAR(25)
);

CREATE TABLE Hub(
                            idHub               VARCHAR(5)   CONSTRAINT pk_Hub_idHub PRIMARY KEY,
                            latitude            NUMBER(6,4),
                            longitude           NUMBER(6,4),
                            idParticipante      VARCHAR(5)
);

CREATE TABLE LogLeiturasInput(
                                 idLog               INTEGER GENERATED ALWAYS AS IDENTITY CONSTRAINT pk_LogLeiturasInput_idLog PRIMARY KEY,
                                 dataLeitura         TIMESTAMP,
                                 registosLidos       NUMBER,
                                 registosInseridos   NUMBER,
                                 registosComErro     NUMBER
);

ALTER TABLE ExploracaoAgricola ADD CONSTRAINT fk_ExploracaoAgricola_idGestorAgricola_GestorAgricola FOREIGN KEY (idGestorAgricola) REFERENCES GestorAgricola (idGestorAgricola);

ALTER TABLE Cliente ADD CONSTRAINT fk_Cliente_idHub_Hub FOREIGN KEY (idHub) REFERENCES Hub (idHub);

ALTER TABLE ClienteExploracaoAgricola ADD CONSTRAINT fk_ClienteExploracaoAgricola_idExploracaoAgricola_ExploracaoAgricola FOREIGN KEY (idExploracaoAgricola) REFERENCES ExploracaoAgricola (idExploracaoAgricola);
ALTER TABLE ClienteExploracaoAgricola ADD CONSTRAINT fk_ClienteExploracaoAgricola_codigoInternoCliente_Cliente FOREIGN KEY (codigoInternoCliente) REFERENCES Cliente (codigoInterno);

ALTER TABLE Morada ADD CONSTRAINT fk_Morada_codigoPostal_CodigoPostal FOREIGN KEY (codigoPostal) REFERENCES CodigoPostal (codigoPostal);
ALTER TABLE Morada ADD CONSTRAINT fk_Morada_codigoInternoCliente_Cliente FOREIGN KEY (codigoInternoCliente) REFERENCES Cliente (codigoInterno);

ALTER TABLE Encomenda ADD CONSTRAINT fk_Encomenda_codigoInternoCliente_Cliente FOREIGN KEY (codigoInternoCliente) REFERENCES Cliente (codigoInterno);
ALTER TABLE Encomenda ADD CONSTRAINT fk_Encomenda_codigoPostalMorada_numeroPortaMorada_Morada FOREIGN KEY (codigoPostalMorada, numeroPortaMorada) REFERENCES Morada (codigoPostal, numeroPorta);
ALTER TABLE Encomenda ADD CONSTRAINT fk_Encomenda_idHub_Hub FOREIGN KEY (idHub) REFERENCES Hub (idHub);

ALTER TABLE Incidente ADD CONSTRAINT fk_Incidente_numeroEncomenda_Encomenda FOREIGN KEY (numeroEncomenda) REFERENCES Encomenda (numeroEncomenda);
ALTER TABLE Incidente ADD CONSTRAINT fk_Incidente_codigoInternoCliente_Cliente FOREIGN KEY (codigoInternoCliente) REFERENCES Cliente (codigoInterno);

ALTER TABLE EstacaoMeteorologica ADD CONSTRAINT fk_EstacaoMeteorologica_idExploracaoAgricola_ExploracaoAgricola FOREIGN KEY (idExploracaoAgricola) REFERENCES ExploracaoAgricola (idExploracaoAgricola);

ALTER TABLE Sensor ADD CONSTRAINT fk_Sensor_idEstacaoMeteorologica_EstacaoMeteorologica FOREIGN KEY (idEstacaoMeteorologica) REFERENCES EstacaoMeteorologica (idEstacaoMeteorologica);
ALTER TABLE Sensor ADD CONSTRAINT fk_Sensor_tipoTipoSensor_TipoSensor FOREIGN KEY (tipoTipoSensor) REFERENCES TipoSensor (tipo);

ALTER TABLE SensorLeituras ADD CONSTRAINT fk_SensorLeituras_identificador_Sensor FOREIGN KEY (identificadorSensor) REFERENCES  Sensor (identificador);
ALTER TABLE SensorLeituras ADD CONSTRAINT fk_SensorLeituras_tipoTipoSensor_Sensor FOREIGN KEY (tipoTipoSensor) REFERENCES  TipoSensor (tipo);

ALTER TABLE Setor ADD CONSTRAINT fk_Setor_ExploracaoAgricola_idExploracaoAgricola FOREIGN KEY (idExploracaoAgricola) REFERENCES ExploracaoAgricola (idExploracaoAgricola);

ALTER TABLE Auditoria ADD CONSTRAINT fk_Auditoria_idGestorAgricola_GestorAgricola FOREIGN KEY (idGestorAgricola) REFERENCES GestorAgricola (idGestorAgricola);
ALTER TABLE Auditoria ADD CONSTRAINT fk_Auditoria_designacaoSetor_idExploracaoAgricola_Setor FOREIGN KEY (designacaoSetor, idExploracaoAgricola) REFERENCES Setor (designacao, idExploracaoAgricola);

ALTER TABLE OperacaoAgricola ADD CONSTRAINT fk_OperacaoAgricola_designacaoSetor_idExploracaoAgricola_Setor FOREIGN KEY (designacaoSetor, idExploracaoAgricola) REFERENCES Setor (designacao, idExploracaoAgricola);

ALTER TABLE FatoresAplicados ADD CONSTRAINT fk_FatoresAplicados_idOperacaoAgricola_OperacaoAgricola FOREIGN KEY (idOperacaoAgricola) REFERENCES OperacaoAgricola (idOperacaoAgricola);
ALTER TABLE FatoresAplicados ADD CONSTRAINT fk_FatoresAplicados_nomeComercialFatorProducao_FatorProducao FOREIGN KEY (nomeComercialFatorProducao) REFERENCES FatorProducao (nomeComercial);

ALTER TABLE Restricao ADD CONSTRAINT fk_Restricao_nomeComercialFatorProducao_FatorProducao FOREIGN KEY (nomeComercialFatorProducao) REFERENCES FatorProducao (nomeComercial);

ALTER TABLE RestricaoSetor ADD CONSTRAINT fk_RestricaoSetor_idRestricao_Restricao FOREIGN KEY (idRestricao) REFERENCES Restricao (idRestricao);
ALTER TABLE RestricaoSetor ADD CONSTRAINT fk_RestricaoSetor_designacaoSetor_idExploracaoAgricola FOREIGN KEY (designacaoSetor, idExploracaoAgricola) REFERENCES Setor (designacao, idExploracaoAgricola);

ALTER TABLE FatorProducaoConstituinte ADD CONSTRAINT fk_FatorProducaoConstituinte_nomeComercialFatorProducao_FatorProducao FOREIGN KEY (nomeComercialFatorProducao) REFERENCES FatorProducao (nomeComercial);
ALTER TABLE FatorProducaoConstituinte ADD CONSTRAINT fk_FatorProducaoConstituinte_nomeConstituinte_Constituinte FOREIGN KEY (nomeConstituinte) REFERENCES Constituinte (nome);

ALTER TABLE Cultura ADD CONSTRAINT fk_Cultura_designacaoSetor_idExploracaoAgricola FOREIGN KEY (designacaoSetor, idExploracaoAgricola) REFERENCES Setor (designacao, idExploracaoAgricola);

ALTER TABLE CulturaProduto ADD CONSTRAINT fk_CulturaProduto_idCultura_Cultura FOREIGN KEY (idCultura) REFERENCES Cultura (idCultura);
ALTER TABLE CulturaProduto ADD CONSTRAINT fk_CulturaProduto_idProduto_Produto FOREIGN KEY (idProduto) REFERENCES Produto (idProduto);

ALTER TABLE Safra ADD CONSTRAINT fk_Safra_idCultura_Cultura FOREIGN KEY (idCultura) REFERENCES Cultura (idCultura);

ALTER TABLE Caracteristica ADD CONSTRAINT fk_Caracteristica_idCultura_Cultura FOREIGN KEY (idCultura) REFERENCES Cultura (idCultura);

ALTER TABLE Parametro ADD CONSTRAINT fk_Parametro_idCaracteristica_Caracteristica FOREIGN KEY (idCaracteristica, idCultura) REFERENCES Caracteristica (idCaracteristica, idCultura);


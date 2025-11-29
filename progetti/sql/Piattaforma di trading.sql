-- ANALISI E PREPARAZIONE DATASET
USE trading;
SELECT * FROM 1000_stock_transactions LIMIT 3;
DESCRIBE `1000_stock_transactions`;
-- Converto timestamp da text a data
ALTER TABLE `1000_stock_transactions` 
MODIFY COLUMN timestamp DATETIME;
-- Converto prezzo da double a decimale
ALTER TABLE `1000_stock_transactions` 
MODIFY COLUMN prezzo DECIMAL(15,4);

-- VOLUME MEDIO DI SCAMBIO
-- Volume medio di scambio con distinzione tra buy e sell
SELECT 
    -- Volume medio totale
    AVG(volume) as volume_medio_totale,
    -- Volume medio solo per operazioni BUY
    AVG(CASE WHEN operazione = 'buy' THEN volume ELSE NULL END) as volume_medio_buy,
    -- Volume medio solo per operazioni SELL
    AVG(CASE WHEN operazione = 'sell' THEN volume ELSE NULL END) as volume_medio_sell,
    -- Volume totale per tipo
    SUM(CASE WHEN operazione = 'buy' THEN volume ELSE 0 END) as volume_totale_buy,
    SUM(CASE WHEN operazione = 'sell' THEN volume ELSE 0 END) as volume_totale_sell,
    -- Conteggio operazioni per tipo
    SUM(CASE WHEN operazione = 'buy' THEN 1 ELSE 0 END) as numero_buy,
    SUM(CASE WHEN operazione = 'sell' THEN 1 ELSE 0 END) as numero_sell,
    -- Totali
    SUM(volume) as volume_totale,
    COUNT(*) as numero_operazioni_totali
FROM `1000_stock_transactions`;
-- Notiamo che ci troviamo con il numero di operazioni totali, ovvero 1000
-- Nel intervallo di tempo analizzato ci sono state più operazioni di SELL rispetto a quelle BUY
-- Inoltre anche il volume medio delle operazioni SELL è stato maggiore sipetto a quelle BUY

-- NUMERO DI OPERAZIONI PER CLIENTE
-- Conta transazioni per cliente, ordinati dal più attivo
SELECT 
    id_cliente,
    COUNT(*) as numero_transazioni,
    SUM(volume) as volume_totale,
    AVG(volume) as volume_medio,
    SUM(prezzo * volume) as valore_totale_transato
FROM `1000_stock_transactions`
GROUP BY id_cliente
ORDER BY numero_transazioni DESC;
-- Attività clienti con dettaglio buy/sell
SELECT 
    id_cliente,
    COUNT(*) as totale_transazioni,
    SUM(CASE WHEN operazione = 'buy' THEN 1 ELSE 0 END) as transazioni_buy,
    SUM(CASE WHEN operazione = 'sell' THEN 1 ELSE 0 END) as transazioni_sell,
    SUM(volume) as volume_totale,
    AVG(prezzo) as prezzo_medio
FROM `1000_stock_transactions`
GROUP BY id_cliente
ORDER BY totale_transazioni DESC;
-- Il cliente che ha fatto più transazioni sono 2, ovvero id 6298 e id 7531. Il primo però ha effetuato più transazioni BUY
-- Media operazioni per cliente
SELECT 
    COUNT(*) / COUNT(DISTINCT id_cliente) as operazioni_medie_per_cliente,
    COUNT(*) as totale_operazioni,
    COUNT(DISTINCT id_cliente) as numero_clienti_unici
FROM `1000_stock_transactions`;
-- Il numero di operazione media per cliente è di 66 operazioni
-- Ci sono 15 clienti che hanno effetuato un unica operazioe

-- ASSET PIÙ SCAMBIATI
-- Volume medio e volume totale per ticker
SELECT 
    ticker,
    AVG(volume) as volume_medio,
    SUM(volume) as volume_totale,
    COUNT(*) as numero_operazioni
FROM `1000_stock_transactions`
GROUP BY ticker
ORDER BY volume_medio DESC;
-- META è l azienda con volume medio più scambiato seguita Amazon, Microsoft e Tesla.
-- Per quanto riguarda il volume totale l'azione più scambiata rimane META seguita da Microsoft, Amazon e Tesla

-- PERIODO DI MAGGIORE ATTIVITÀ
-- Volume medio scambiato per giorno
SELECT 
    DATE(timestamp) as data,
    AVG(volume) as volume_medio_giornaliero,
    COUNT(*) as numero_operazioni
FROM `1000_stock_transactions`
GROUP BY DATE(timestamp)
ORDER BY volume_medio_giornaliero DESC;
-- Il giorno con volume medio più alto è stato il 1 gennaio anche se dovuta ad una sola transazione
-- Invece il giorno con un alto volume medio dcollegato a varie transazioni è stato il 24 maggio
-- Volume medio scambiato per mese
SELECT 
    DATE_FORMAT(timestamp, '%Y-%m') as anno_mese,
    AVG(volume) as volume_medio_mensile,
    SUM(volume) as volume_totale_mensile,
    COUNT(*) as numero_operazioni
FROM `1000_stock_transactions`
GROUP BY DATE_FORMAT(timestamp, '%Y-%m')
ORDER BY volume_medio_mensile DESC;
-- Possiamo notare come Marzo è sato il mese con il volume medio di scambio più elevato seguito da Gennaio, Febbraio, Aprile e Maggio
-- I 10 giorni con più transazioni
SELECT 
    DATE(timestamp) as data,
    COUNT(*) as numero_transazioni,
    SUM(volume) as volume_totale,
    AVG(volume) as volume_medio
FROM `1000_stock_transactions`
GROUP BY DATE(timestamp)
ORDER BY numero_transazioni DESC
LIMIT 10;
-- Il 20 aprile è stato il giorno con più transazioni eseguitee anche quello con volume totale e medio maggiore rispetto agli altri
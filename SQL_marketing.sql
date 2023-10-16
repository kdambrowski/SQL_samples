-- What is cost per order for different actions? Cost per order = costs/number of orders
SELECT ACTION_NAME, AVG(COST/ORDERS) AS 'Cost per order' 
FROM ACTION_DATA_1 GROUP BY ACTION_NAME;

-- On which channel most money was spent? On which the least?  
SELECT max_price.COST AS MAX_MONEY_SPEND_CHANNEL_NAME,
 min_price.COST AS MIN_MONEY_SPEND_CHANNEL_NAME
FROM (
    SELECT 'CHANNEL', COST
    FROM ACTION_DATA_1
    WHERE COST = (SELECT MAX(COST) FROM ACTION_DATA_1)
) AS max_price
JOIN (
    SELECT 'CHANNEL', COST
    FROM ACTION_DATA_1
    WHERE COST = (SELECT MIN(COST) FROM ACTION_DATA_1)
) AS min_price ON 'max_price.CHANNEL' <> 'min_price.CHANNEL';

-- How many orders there are for actions that costed less than 45k?  
-- THE SAME AUSSUMPTION LIKE AT TASK 1
SELECT 'ACTION_ID', SUM(ORDERS) FROM ACTION_DATA_1
WHERE COST < 45000
GROUP BY 'ACTION_ID';

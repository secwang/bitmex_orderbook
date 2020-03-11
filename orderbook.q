\l /Users/secwang/q/playground/cryptoq.q
\l /Users/secwang/q/playground/qbitmex.q
settings:`apiHost`apiKey`apiSecret!("www.bitmex.com";"";"")   //testnet
trade:([]timestamp:`timestamp$();price:`float$();side:`symbol$();size:`float$());
quote:([]timestamp:`timestamp$();bidSize:`float$();bidPrice:`float$();askSize:`float$();askPrice:`float$());
liquidation:([]timestamp:`timestamp$();size:`float$();price:`float$();leavesQty:`float$());
orderbook:([]symbol:`symbol$();id:`long$();side:`symbol$();size:`long$();price:`float$());

trade_dispatch:{[xx] if[xx[`action]~"insert";`trade insert select ltime`timestamp$"Z"$timestamp,`float$price, `$side ,`float$size from xx[`data]]}

quote_dispatch:{[x] if[x[`action]~"insert";`quote insert select ltime`timestamp$"Z"$timestamp,`float$bidSize, `float$bidPrice ,`float$askPrice,`float$askSize from x[`data]]}
liquidation_dispatch:{[x] if[x[`action]~"insert";show x[`data]]}
orderbook_dispatch:{[x] if[x[`action]~"partial";orderbook_partial[x]];if[x[`action]~"insert"; orderbook_insert[x]];if[x[`action]~"update";orderbook_update[x]];if[x[`action]~"delete"; orderbook_delete[x]]; }
/ todo when receive partial , clear orderbook
orderbook_partial:{[x] `orderbook insert select `$symbol,`long$id,`$side ,`long$size,`float$price from x[`data]}
orderbook_insert:{[x] `orderbook insert select `$symbol,`long$id,`$side ,`long$size,`float$price from x[`data]}
orderbook_update:{[x] xx:select `$symbol,`long$id,`$side ,`long$size from x[`data]; {[row] update side:row[`side], size:row[`size] from `orderbook where id = row[`id]} each xx}
orderbook_delete:{[x]  xx:select `$symbol,`long$id,`$side from x[`data];delete from `orderbook where id in xx[`id]}

.z.ws:{xx::.j.k[x];if[xx[`table]~"trade";trade_dispatch[xx]];if[xx[`table]~"quote" ; quote_dispatch[xx]];if[xx[`table]~"liquidation" ; liquidation_dispatch[xx]];if[xx[`table]~"orderBookL2";orderbook_dispatch[xx]]};

wsh:wsapi[settings`apiHost; settings`apiKey; settings`apiSecret];
wsapi_sub[first[wsh];"trade:XBTUSD"]
wsapi_sub[first[wsh];"quote:XBTUSD"]
wsapi_sub[first[wsh];"liquidation:XBTUSD"]
wsapi_sub[first[wsh];"orderBookL2:XBTUSD"]

/wsapi_unsub[first[wsh];"quote:XBTUSD"]
/wsapi_unsub[first[wsh];"trade:XBTUSD"]

/ another comment
select [-10] from trade
select [-100] from orderbook 
`price xdesc select from orderbook where side = `Buy
`price xasc select from orderbook where side = `Sell
`size xdesc select from orderbook where side = `Buy
`size xdesc select from orderbook where side = `Sell

\

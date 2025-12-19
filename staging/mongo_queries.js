/*
  Grupo 5
  202300133, Filipe Rodrigues Patricio
  202300532, José Vicente Camolas da Silva
*/


// Excluão de valores omissos e ordenação
db.productSales.find(
    {TotalSales: {$exists: true})
    ).sort({TotalSales: -1}


// Filtragem
db.customerPurchases.find(
    {TotalSpent: {$gt: 5000}}
    ).sort({TotalSpent: -1})


// Agregação
db.salesSummary.aggregate([
    {
        $group: {
            _id: "$Year",
            TotalSales: {$sum: "$TotalSales"}
            }},{$sort: {_id: 1}}])

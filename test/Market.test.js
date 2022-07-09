const Market = artifacts.require("Market");

contract("Market", async accounts => {
  let market;
  const user0 = accounts[0];
  const user1 = accounts[1];
  const user2 = accounts[2];
  
  beforeEach(async () => {
    market = await Market.new();
  })

  it("should add a buy offer.", async () => {
    await market.addBuyOffer("MSFT", {value: 100, from: user1});
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0].value, 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
  });

  it("should add multiple buy offers.", async () => {
    await market.addBuyOffer("MSFT", {value: 100, user0});
    await market.addBuyOffer("MSFT", {value: 105, user1});
    await market.addBuyOffer("MSFT", {value: 95, user2});
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0].value, 95);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[1].value, 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[2].value, 105);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
  });

  it("should throw if adding a sell offer with no stock", async () => {
    try {
      await market.addSellOffer("MSFT", 100, {from: user0});
      assert(false);
    } catch (error) {
      assert(error);
    }
  });

  it("should add a sell offer.", async () => {
    await market.setStockCount("MSFT", 5, {from: user0});

    await market.addSellOffer("MSFT", 100, {from: user0});
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[0].value, 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 0);
  });

  it("should add multiple sell offers.", async () => {
    await market.setStockCount("MSFT", 5, {from: user0});
    await market.setStockCount("MSFT", 5, {from: user1});
    await market.setStockCount("MSFT", 5, {from: user2});

    await market.addSellOffer("MSFT", 100, {from: user0});
    await market.addSellOffer("MSFT", 105, {from: user1});
    await market.addSellOffer("MSFT", 95, {from: user2});
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[0].value, 105);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[1].value, 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[2].value, 95);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 0);
  });

  it("should execute a trade.", async () => {
    await market.setStockCount("MSFT", 5, {from: user1});

    await market.addBuyOffer("MSFT", {value: 95, user0});
    await market.addSellOffer("MSFT", 105, {from: user1});
    await market.addBuyOffer("MSFT", {value: 110, user2});
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 1);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0].value, 95);
  })
})

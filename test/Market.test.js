const Market = artifacts.require("Market");

contract("Market", async accounts => {
  let market;
  
  beforeEach(async () => {
    market = await Market.new();
  })

  it("should add a buy offer.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.BUY);
    // From what I can tell, this is NOT the correct way to verify behavior in a javascript test.
    // I think this sort of thing belongs in a solidity unit test. But we'll make do with this.
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0], 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
  });

  it("should add multiple buy offers.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.BUY);
    await market.addOffer("MSFT", 105, Market.OfferType.BUY);
    await market.addOffer("MSFT", 95, Market.OfferType.BUY);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0], 95);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[1], 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[2], 105);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
  });

  it("should add a sell offer.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.SELL);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[0], 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 0);
  });

  it("should add multiple sell offers.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.SELL);
    await market.addOffer("MSFT", 105, Market.OfferType.SELL);
    await market.addOffer("MSFT", 95, Market.OfferType.SELL);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[0], 105);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[1], 100);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL))[2], 95);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 0);
  });

  it("should execute a trade.", async () => {
    await market.addOffer("MSFT", 95, Market.OfferType.BUY);
    await market.addOffer("MSFT", 105, Market.OfferType.SELL);
    await market.addOffer("MSFT", 110, Market.OfferType.BUY);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.SELL)).length, 0);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY)).length, 1);
    assert.equal((await market.viewOffers("MSFT", Market.OfferType.BUY))[0], 95);
  })
})

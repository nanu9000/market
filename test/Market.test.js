const Market = artifacts.require("Market");

// TODO: Right now, the only way I can assert anything is to look at events as tests happen.
// Need something better.
contract("Market", async accounts => {
  let market;
  
  beforeEach(async () => {
    market = await Market.new();
  })

  it("should add a buy offer.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.BUY);
  });

  it("should add multiple buy offers.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.BUY);
    await market.addOffer("MSFT", 105, Market.OfferType.BUY);
    await market.addOffer("MSFT", 95, Market.OfferType.BUY);
  });

  it("should add a sell offer.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.SELL);
  });

  it("should add multiple sell offers.", async () => {
    await market.addOffer("MSFT", 100, Market.OfferType.SELL);
    await market.addOffer("MSFT", 105, Market.OfferType.SELL);
    await market.addOffer("MSFT", 95, Market.OfferType.SELL);
  });

  it("should add buy and sell orders.", async () => {
    await market.addOffer("MSFT", 95, Market.OfferType.BUY);
    await market.addOffer("MSFT", 105, Market.OfferType.SELL);
    await market.addOffer("MSFT", 110, Market.OfferType.BUY);
    assert.ok(false);
  })
})

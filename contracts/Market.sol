// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Market {
  mapping(address => Portfolio) private portfolios;
  mapping(string => OfferList) private openOffers;

  enum OfferType { BUY, SELL }

  struct Portfolio {
    mapping (string => uint) stockHoldings;
  }

  struct Offer {
    uint value;
    address payable user;
  }

  // Buys are increasing and sells are decreasing so that executing trades is just popping off the end
  struct OfferList {
    Offer[] orderedBuyOffers;
    Offer[] orderedSellOffers;
  }

  // @VisibleForTesting
  function setStockCount(string calldata ticker, uint numStocks) external {
    portfolios[msg.sender].stockHoldings[ticker] = numStocks;
  }

  function addBuyOffer(string calldata ticker) external payable {
    OfferList storage offers = openOffers[ticker];
    Offer memory offer = Offer(msg.value, payable(msg.sender));
    offers.orderedBuyOffers.push(offer);
    offers.orderedBuyOffers = sort(offers.orderedBuyOffers, true);
    executeTrades(ticker);
    emit AllOffers(OfferType.BUY, offers.orderedBuyOffers, offers.orderedSellOffers);
  }

  function addSellOffer(string calldata ticker, uint value) external {
    // This would normally be possible, but we're not doing it here.
    require(portfolios[msg.sender].stockHoldings[ticker] > 0, "Seller is selling stock that they don't have.");
    portfolios[msg.sender].stockHoldings[ticker] -= 1;
    OfferList storage offers = openOffers[ticker];
    Offer memory offer = Offer(value, payable(msg.sender));
    offers.orderedSellOffers.push(offer);
    offers.orderedSellOffers = sort(offers.orderedSellOffers, false);
    executeTrades(ticker);
    emit AllOffers(OfferType.SELL, offers.orderedBuyOffers, offers.orderedSellOffers);
  }

  function executeTrades(string calldata ticker) private {
    while (canExecuteTrade(ticker)) {
      executeTrade(ticker);
    }
  }

  function canExecuteTrade(string calldata ticker) private view returns (bool) {
    OfferList storage offers = openOffers[ticker];
    return offers.orderedBuyOffers.length > 0 && offers.orderedSellOffers.length > 0 &&
        offers.orderedBuyOffers[offers.orderedBuyOffers.length - 1].value >= offers.orderedSellOffers[offers.orderedSellOffers.length - 1].value;
  }

  function executeTrade(string calldata ticker) private {
    Offer storage buyOffer = openOffers[ticker].orderedBuyOffers[openOffers[ticker].orderedBuyOffers.length - 1];
    Offer storage sellOffer = openOffers[ticker].orderedSellOffers[openOffers[ticker].orderedSellOffers.length - 1];

    uint price = uint((buyOffer.value + sellOffer.value) / 2);
    if (sellOffer.user.send(price)) {
      emit Trade(ticker, openOffers[ticker].orderedBuyOffers[openOffers[ticker].orderedBuyOffers.length - 1], openOffers[ticker].orderedSellOffers[openOffers[ticker].orderedSellOffers.length - 1]);
      portfolios[buyOffer.user].stockHoldings[ticker] += 1;
      portfolios[sellOffer.user].stockHoldings[ticker] -= 1;
      openOffers[ticker].orderedBuyOffers.pop();
      openOffers[ticker].orderedSellOffers.pop();
    }
  }

  // @VisibleForTesting
  function viewOffers(string calldata ticker, OfferType offerType) public view returns (Offer[] memory) {
    return offerType == OfferType.BUY ? openOffers[ticker].orderedBuyOffers : openOffers[ticker].orderedSellOffers;
  }

  /**
   * Quicksort functions.
   * TODO: Move this to a separate file.
   */
  function sort(Offer[] storage data, bool isIncreasing) private returns(Offer[] storage) {
    quickSort(data, int(0), int(data.length - 1), isIncreasing);
    return data;
  }
  
  function quickSort(Offer[] storage arr, int left, int right, bool isIncreasing) private {
    int i = left;
    int j = right;
    if(i==j) return;
    Offer storage pivot = arr[uint(left + (right - left) / 2)];
    int iter = 0;
    while (i <= j) {
      while (compare(arr[uint(i)], pivot, isIncreasing)) i++;
      while (compare(pivot, arr[uint(j)], isIncreasing)) j--;
      if (i <= j) {
        Offer memory temp = arr[uint(j)];
        arr[uint(j)] = arr[uint(i)];
        arr[uint(i)] = temp;
        // The following syntactic sugar doesn't work in storage
        // (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
        i++;
        j--;
      }

      iter++;
    }
    if (left < j)
      quickSort(arr, left, j, isIncreasing);
    if (i < right)
      quickSort(arr, i, right, isIncreasing);
  }

  function compare(Offer storage a, Offer storage b, bool isIncreasing) private view returns (bool) {
    if (isIncreasing) {
      return a.value < b.value;
    } else {
      return b.value < a.value;
    }
  }

  event AllOffers(OfferType offerType, Offer[] buys, Offer[] sells);
  event Trade(string ticker, Offer buyOffer, Offer sellOffer);
}

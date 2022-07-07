// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract Market {
  mapping(string => OfferList) private openOffers;

  enum OfferType { BUY, SELL }

  // Buys are increasing and sells are decreasing so that executing trades is just popping off the end
  struct OfferList {
    uint32[] orderedBuyOffers;
    uint32[] orderedSellOffers;
  }

  function addOffer(string calldata ticker, uint32 offer, OfferType offerType) public {
    OfferList storage offers = openOffers[ticker];
    if (offerType == OfferType.BUY) {
      offers.orderedBuyOffers.push(offer);
      offers.orderedBuyOffers = sort(offers.orderedBuyOffers, true);
      emit Offers(offers.orderedBuyOffers, offers.orderedSellOffers);
    } else if (offerType == OfferType.SELL) {
      offers.orderedSellOffers.push(offer);
      offers.orderedSellOffers = sort(offers.orderedSellOffers, false);
      emit Offers(offers.orderedBuyOffers, offers.orderedSellOffers);
    } else {
      require(false, "Offer type must be either buy or sell.");
    }

    executeTrades(ticker);
    emit Offers(offers.orderedBuyOffers, offers.orderedSellOffers);
  }

  function executeTrades(string calldata ticker) private {
    while (canExecuteTrade(ticker)) {
      executeTrade(ticker);
    }
  }

  function canExecuteTrade(string calldata ticker) private view returns (bool) {
    OfferList storage offers = openOffers[ticker];
    return offers.orderedBuyOffers.length > 0 && offers.orderedSellOffers.length > 0 &&
        offers.orderedBuyOffers[offers.orderedBuyOffers.length - 1] >= offers.orderedSellOffers[0];
  }

  function executeTrade(string calldata ticker) private {
    openOffers[ticker].orderedBuyOffers.pop();
    openOffers[ticker].orderedSellOffers.pop();
  }

  /**
   * Quicksort functions.
   * TODO: Move this to a separate file.
   * TODO: This doesn't work if you switch 'memory' for 'storage' and I don't know why.
   */
  function sort(uint32[] memory data, bool isIncreasing) private returns(uint32[] memory) {
    quickSort(data, int(0), int(data.length - 1), isIncreasing);
    return data;
  }
  
  function quickSort(uint32[] memory arr, int left, int right, bool isIncreasing) private {
    int i = left;
    int j = right;
    if(i==j) return;
    uint32 pivot = arr[uint(left + (right - left) / 2)];
    int iter = 0;
    while (i <= j) {
      // while (arr[uint(i)] < pivot) i++;
      // emit Array(arr, 0, iter, i, j, left, right);
      while (compare(arr[uint(i)], pivot, isIncreasing)) i++;
      // emit Array(arr, 1, iter, i, j, left, right);
      // while (pivot < arr[uint(j)]) j--;
      while (compare(pivot, arr[uint(j)], isIncreasing)) j--;
      // emit Array(arr, 2, iter, i, j, left, right);
      if (i <= j) {
        (arr[uint(i)], arr[uint(j)]) = (arr[uint(j)], arr[uint(i)]);
        i++;
        j--;
      }

      // emit Array(arr, 3, iter, i, j, left, right);
      iter++;
    }
    if (left < j)
      quickSort(arr, left, j, isIncreasing);
    if (i < right)
      quickSort(arr, i, right, isIncreasing);
  }

  function compare(uint32 a, uint32 b, bool isIncreasing) private pure returns (bool) {
    if (isIncreasing) {
      return a < b;
    } else {
      return b < a;
    }
  }

  event Offers(uint32[] buys, uint32[] sells);
}

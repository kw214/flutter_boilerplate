import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:trending_api/trending_api.dart';
import 'package:trending_repository/trending_repository.dart';

part 'trending_event.dart';

part 'trending_state.dart';

class TrendingBloc extends Bloc<TrendingEvent, TrendingState> {
  TrendingBloc({
    required TrendingRepository trendingRepository,
  })  : _trendingRepository = trendingRepository,
        super(const TrendingState()) {
    on<TrendingSubscriptionRequested>(_onSubscriptionRequested);
  }

  final TrendingRepository _trendingRepository;

  Future<void> _onSubscriptionRequested(
    TrendingSubscriptionRequested event,
    Emitter<TrendingState> emit,
  ) async {
    emit(state.copyWith(
      status: TrendingStatus.loading,
      operation: event.operation,
    ));

    await emit.forEach<List<Trending>?>(
      _trendingRepository
          .getTrending(pullDown: event.operation == TrendingOperation.refresh)
          .asStream(),
      onData: (trendingList) => state.copyWith(
        status: TrendingStatus.success,
        operation: TrendingOperation.none,
        trendingList: trendingList,
      ),
      onError: (_, __) => state.copyWith(
        status: TrendingStatus.failure,
        operation: TrendingOperation.none,
      ),
    );
  }
}

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

/// Base class for all BLoC events
abstract class BaseEvent extends Equatable {
  const BaseEvent();

  @override
  List<Object?> get props => [];
}

/// Base class for all BLoC states
abstract class BaseState extends Equatable {
  const BaseState();

  @override
  List<Object?> get props => [];
}

/// Base class for all BLoCs
abstract class BaseBloc<Event extends BaseEvent, State extends BaseState>
    extends Bloc<Event, State> {
  BaseBloc(State initialState) : super(initialState);
}

/// Loading state mixin for states that can show loading
mixin LoadingState {
  bool get isLoading;
}

/// Error state mixin for states that can show errors
mixin ErrorState {
  String? get errorMessage;
}

/// Success state mixin for states that can show success
mixin SuccessState {
  String? get successMessage;
}

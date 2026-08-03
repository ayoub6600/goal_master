@extends('layouts.app')
@section('content')
<style>
  div p {
    font-weight: bold;
  }

  .unread .text-muted {
    color: white !important;
  }

  .text-muted {
    text-align: left !important;
    direction: ltr !important;
    font-weight: normal !important;
  }
</style>
@if (session('success'))
<div class="alert alert-success">
  {{ session('success') }}
</div>
@endif
<h2 style="text-align: center" class="m-4">جميع الاشعارات</h2>
<form action="{{ route('notifications.markAsRead') }}" method="POST">
  @csrf
  <button type="submit" class="btn btn-primary btn-sm mx-5">Mark All as Read</button>
</form>
<div class="container mt-4" style="direction: rtl; text-align: right">

  @if ($notifications->count() > 0)
  <ul class="list-group">
    @foreach ($notifications as $notification)
    @php
    $id = isset($notification->data['id']) ? json_encode($notification->data['id']) : null;
    @endphp
    @if($notification->unread())
    <div class="notif-content unread">
      <span class="block">
        {{ ($notification->data['message']) }}
      </span>
      @if($id)
      <a class="details" onclick="fetchBookingDetails('{{ $id }}')">عرض تفاصيل الحجز >></a>
      @endif
      <span class="time">{{ $notification->created_at->diffForHumans() }}</span>
    </div>
    @else
    <div class="notif-content">
      <span class="block">
        {{ ($notification->data['message']) }}
      </span>
      @if($id)
      <a class="details" onclick="fetchBookingDetails('{{ $id }}')">عرض تفاصيل الحجز >></a>
      @endif
      <span class="time">{{ $notification->created_at->diffForHumans() }}</span>
    </div>
    @endif
    @endforeach
  </ul>
  @else
  <p class="text-center">No notifications available.</p>
  @endif
</div>
@endsection
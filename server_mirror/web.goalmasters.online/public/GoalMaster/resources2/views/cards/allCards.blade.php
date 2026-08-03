@extends('layouts.app')
@section('content')
@push("adminScripts")
<script src="{{ dsAsset('js/custom/user_management/user.js') }}"></script>
<link href="{{ 'css/custom/user_management/login.css' }}" rel="stylesheet" />
@endpush
<script>
    $(document).ready(function() {
        isHeaderScrolled = 0;
    });
</script>

<script>
    // Automatically hide the alert after 3 seconds
    setTimeout(function() {
        let successAlert = document.getElementById('success-alert');
        if (successAlert) {
            successAlert.classList.remove('show');
            successAlert.classList.add('fade');
        }
    }, 3000); // 3000 milliseconds = 3 seconds
</script>

<style>
    .slide-down {
        animation: slideDown 0.5s ease-out;
        /* Animation duration and easing */
    }

    @keyframes slideDown {
        from {
            top: -100px;
            /* Start above the viewport */
            opacity: 0;
        }

        to {
            top: 20px;
            /* End at a position slightly below the top */
            opacity: 1;
        }
    }

    .table {
        background-color: #f9f9f9;
        border-radius: 10px;
        overflow: hidden;
    }

    .table th,
    .table td {
        padding: 15px;
        text-align: center;
        vertical-align: middle;
    }

    .table th {
        background-color: #007bff;
        color: white;
    }

    .btn-primary {
        background-color: #007bff;
        border-color: #007bff;
    }

    .filter-form {
        background-color: #f1f1f1;
        padding: 20px;
        border-radius: 10px;
        margin-bottom: 20px;
    }

    .filter-form input,
    .filter-form select {
        margin-bottom: 10px;
    }

    .clear-filter {
        margin-right: 10px;
        background-color: transparent;
        color: red;
        cursor: pointer;
        font-size: 0.9em;
    }
</style>

<!-- Success Message -->
@if (session('success'))
<div class="alert alert-success alert-dismissible fade show slide-down" role="alert" id="success-alert" style="position: fixed; top: 10%; left: 50%; transform: translate(-50%, -50%); z-index: 9999; min-width: 300px; text-align: center;">
    {{ session('success') }}
    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
        <span aria-hidden="true">&times;</span>
    </button>
</div>
@endif

<div class="container" dir="rtl">
    <form method="GET" action="{{ route('getcards') }}" class="mb-3 filter-form">
        <div class="d-flex flex-column">
            <div class="row mb-2 col-12" style="gap: 10px">
                <div class="row mb-2 col-4" >
                    <label for="group_id" class="form-label float-right">{{translate('Group Id')}}</label>
                    <input type="text" name="group_id" id="group_id" value="{{ request()->group_id }}" class="form-control" placeholder="Group ID">
                </div>
                <div class="row mb-2  col-4">
                    <label for="formula" class="form-label float-right">{{translate('Formula')}}</label>
                    <select name="formula" id="formula" class="form-control form-control-sm ">
                        <option value="">{{translate('Select Formula')}}</option>
                        <option value="numbers" {{ request()->formula == 'numbers' ? 'selected' : '' }}>{{translate('Numbers')}}</option>
                        <option value="letters" {{ request()->formula == 'letters' ? 'selected' : '' }}>{{translate('Letters')}}</option>
                        <option value="both" {{ request()->formula == 'both' ? 'selected' : '' }}>{{translate('Letters & Numbers')}}</option>
                    </select>
                </div>
            </div>
            <div class="row mb-2 col-12" style="gap: 10px">
                <div class="row mb-2 col-4">
                    <label for="count_from" class="form-label float-right">{{translate('Count From')}}</label>
                    <input type="number" name="count_from" id="count_from" value="{{ request()->count_from }}" class="form-control">
                </div>
                <div class="row mb-2 col-4">
                    <label for="count_to" class="form-label float-right">{{translate('To')}}</label>
                    <input type="number" name="count_to" id="count_to" value="{{ request()->count_to }}" class="form-control">
                </div>
            </div>
            <div class="row mb-2 col-12" style="gap: 10px">
                <div class="row mb-2 col-4">
                    <label for="price_from" class="form-label float-right">{{translate('Price From')}}</label>
                    <input type="number" name="price_from" id="price_from" value="{{ request()->price_from }}" class="form-control" placeholder="Price From">
                </div>
                <div class="row mb-2 col-4">
                    <label for="price_to" class="form-label float-right">{{translate('To')}}</label>
                    <input type="number" name="price_to" id="price_to" value="{{ request()->price_to }}" class="form-control" placeholder="Price To">
                </div>
            </div>
            <div class="row mb-2 col-12" style="gap: 10px">
                <div class="row mb-2 col-4">
                    <label for="date_from" class="form-label float-right">{{translate('Date From')}}</label>
                    <input type="datetime-local" name="date_from" id="date_from" value="{{ request()->date_from }}" class="form-control" placeholder="Date From">
                </div>
                <div class="row mb-2 col-4">
                    <label for="date_to" class="form-label float-right">{{translate('To')}}</label>
                    <input type="datetime-local" name="date_to" id="date_to" value="{{ request()->date_to }}" class="form-control" placeholder="Date To">
                </div>
            </div>
        </div>
        <div class="col-3 mb-2 d-flex justify-content-between">
            <button type="submit" class="btn btn-primary">{{translate('Filter')}}</button>
            <a href="{{ route('getcards') }}" class="btn btn-secondary">{{translate('Clear Filters')}}</a>
        </div>
    </form>


    <!-- Create a table to display card data -->
    <table class="table table-bordered mb-5">
        <thead>
            <tr>
                <th>{{translate('Group Id')}}</th>
                <th>{{translate('Count')}}</th>
                <th>{{translate('Formula')}}</th>
                <th>{{translate('Price')}}</th>
                <th>{{translate('Created At')}}</th>
                <th>{{translate('Action')}}</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($groups as $group)
            <tr>
                <td>{{ $group->id}}</td>
                <td>{{ $group->count }}</td>
                <td>{{ translate($group->formula) }}</td>
                <td>{{ $group->price }}</td>
                <td>{{ $group->created_at->format('Y-m-d H:i:s') }}</td>
                <td>
                    <a href="{{ route('cards.pdf', $group->id) }}" class="btn btn-primary">{{translate('Download PDF')}}</a>
                </td>
            </tr>
            @empty
            <tr>
                <td colspan="5" class="text-center">{{translate('No cards available.')}}</td>
            </tr>
            @endforelse
        </tbody>
    </table>
</div>
@endsection
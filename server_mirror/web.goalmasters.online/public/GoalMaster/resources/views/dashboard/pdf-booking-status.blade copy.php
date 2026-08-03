<!DOCTYPE html>
<html>
<head>
    <title>Booking Status Report</title>
    <style>
        body { font-family: Arial, sans-serif; }
        .status-table { width: 100%; border-collapse: collapse; }
        .status-table, .status-table th, .status-table td { border: 1px solid #000; padding: 8px; text-align: center; }
    </style>
</head>
@php
    $statusMapping = [
        1 => 'Pending',
        2 => 'Approved',
        3 => 'Processing',
        4 => 'Done',
        5 => 'Cancelled',
    ];

    $totalServiceCount = $bookingData->sum('serviceCount');

@endphp

<body>
    <h2>Booking Status Report</h2>
    <p>Date Range: {{ $startDate }} - {{ $endDate }}</p>

    <table class="status-table">
        <thead>
            <tr>
                <th>Status</th>
                <th>Service Count</th>
            </tr>
        </thead>
        <tbody>
            @foreach ($bookingData as $status)
                <tr>
                    <td>{{ $statusMapping[$status->status] ?? 'Unknown' }}</td>
                    <td>{{ $status->serviceCount }}</td>
                </tr>
            @endforeach
        </tbody>
        <tfoot>
        <tr>
            <td><strong>Total</strong></td>
            <td><strong>{{ $totalServiceCount }}</strong></td>
        </tr>
    </tfoot>
    </table>
</body>
</html>

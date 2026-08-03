<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cards List</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            text-align: center;
            background-color: #f9f9f9;
            margin: 0;
            padding: 20px;
        }

        h1 {
            text-align: center;
            color: #333;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin: 20px 0;
            font-size: 16px;
            min-width: 400px;
        }

        table th,
        table td {
            border: 1px solid #ddd;
            padding: 12px;
        }

        table th {
            background-color: #f2f2f2;
            color: #333;
        }

        table tbody tr:nth-child(even) {
            background-color: #f9f9f9;
        }

        table tbody tr:nth-child(odd) {
            background-color: #fff;
        }

        table tbody tr:hover {
            background-color: #f1f1f1;
        }

        th,
        td {
            padding: 12px 15px;
        }

        th {
            background-color: #4CAF50;
            color: white;
        }

        td {
            color: #333;
        }

        .text-center {
            text-align: center;
        }

        .no-cards {
            color: #a0a0a0;
            font-size: 18px;
        }
    </style>
</head>

<body>

    <h1>Cards List</h1>

    <table>
        <thead>
            <tr>
                <th>#</th>
                <th>Card Code</th>
                <th>Price</th>
                <th>Status</th>
                <th>Created At</th>
            </tr>
        </thead>
        <tbody>
            @forelse ($cards as $card)
            <tr>
                <td>{{ $loop->iteration }}</td>
                <td>{{ $card->code }}</td>
                <td>{{ $card->group->price }}</td>
                <td>{{ $card->is_charged ? 'Charged' : 'Not Charged' }}</td>
                <td>{{ $card->created_at->format('Y-m-d H:i:s') }}</td>
            </tr>
            @empty
            <tr>
                <td colspan="5" class="text-center no-cards">No cards available.</td>
            </tr>
            @endforelse
        </tbody>
    </table>

</body>

</html>
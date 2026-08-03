@extends('layouts.app')

@section('content')
  @if(Auth::user()->is_sys_adm == 1)

    <!-- Toastr CSS -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.css" />

    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

    <!-- Toastr JS -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/toastr.js/latest/toastr.min.js"></script>

    <!-- DataTables CSS -->
    <link rel="stylesheet" href="https://cdn.datatables.net/1.13.6/css/dataTables.bootstrap4.min.css" />
    <link rel="stylesheet" href="https://cdn.datatables.net/responsive/2.5.0/css/responsive.bootstrap4.min.css" />

    <!-- DataTables JS -->
    <script src="https://cdn.datatables.net/1.13.6/js/jquery.dataTables.min.js"></script>
    <script src="https://cdn.datatables.net/1.13.6/js/dataTables.bootstrap4.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/dataTables.responsive.min.js"></script>
    <script src="https://cdn.datatables.net/responsive/2.5.0/js/responsive.bootstrap4.min.js"></script>

    <div class="page-inner">

        <div class="main-card card">
            <div class="card-header d-flex align-items-center">
                <h4 class="card-title">إدارة السلايدر</h4>
                <a href="{{ route('slider.create') }}"
                   class="btn btn-primary btn-sm btn-round ml-auto d-flex align-items-center">
                    <i class="fa fa-plus mr-1"></i> إضافة شريحة جديدة
                </a>
            </div>

            <div class="card-body">
                <table id="sliderTable" class="table table-bordered table-striped dt-responsive nowrap" style="width:100%">
                    <thead>
                    <tr>
                        <th>الرقم</th>
                        <th>الاسم</th>
                        <th>الرابط</th>
                        <th>الحالة</th>
                        <th>الصورة</th>
                        <th>الإجراءات</th>
                    </tr>
                    </thead>
                    <tbody>
                    @foreach($slides as $slide)
                        <tr>
                            <td>{{ $slide->id }}</td>
                            <td>{{ $slide->name }}</td>
                            <td><a href="{{ $slide->url }}" target="_blank">{{ $slide->url }}</a></td>
                            <td>
                                @if ($slide->status === 'active')
                                    نشط
                                @elseif ($slide->status === 'inactive')
                                    غير نشط
                                @else
                                    غير معروف
                                @endif
                            </td>
                            <td>
                                <img src="{{ $slide->image }}" alt="{{ $slide->name }}" style="max-width: 100px; max-height: 70px; object-fit: contain;">
                            </td>
                            <td>
                                <a href="{{ route('slider.edit', $slide->id) }}" class="btn btn-info btn-sm mb-1">تعديل</a>

                                <form action="{{ route('slider.destroy', $slide->id) }}" method="POST" style="display:inline-block;"
                                      onsubmit="return confirm('هل أنت متأكد من حذف هذه الشريحة؟');">
                                    @csrf
                                    @method('DELETE')
                                    <button class="btn btn-danger btn-sm" type="submit">حذف</button>
                                </form>
                            </td>
                        </tr>
                    @endforeach
                    </tbody>
                </table>
            </div>

        </div>
    </div>

    <script>
        $(document).ready(function() {
            $('#sliderTable').DataTable({
                language: {
                    url: '//cdn.datatables.net/plug-ins/1.13.6/i18n/ar.json'
                },
                responsive: true,
                pageLength: 10,
                lengthMenu: [[10, 25, 50, -1], [10, 25, 50, "الكل"]],
                order: [[0, 'asc']]
            });

            @if(session('success'))
                toastr.options = {
                "closeButton": true,
                "progressBar": true,
                "positionClass": "toast-top-left",
                "timeOut": "4000"
            };
            toastr.success("{{ session('success') }}");
            @endif

                    @if(session('error'))
                toastr.options = {
                "closeButton": true,
                "progressBar": true,
                "positionClass": "toast-top-left",
                "timeOut": "4000"
            };
            toastr.error("{{ session('error') }}");
            @endif
        });
    </script>
    @endif
@endsection
